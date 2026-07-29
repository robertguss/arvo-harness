"""Harbor adapter: install Arvo Mix release tarball and run `arvo-chat`.

Translates Harbor instruction → headless Arvo product path (KTD-D1 / KTD-H1).
Does **not** use the Ore single-binary packaging shape. Credentials from env only.
"""

from __future__ import annotations

import os
import shlex
from pathlib import Path
from typing import override

from harbor.agents.base import BaseAgent
from harbor.environments.base import BaseEnvironment
from harbor.models.agent.context import AgentContext


class ArvoAgent(BaseAgent):
    """Drive real headless `arvo-chat` with progressive-attention treatment."""

    SUPPORTS_ATIF = False
    SUPPORTS_RESUME = False
    SUPPORTS_WINDOWS = False

    def __init__(
        self,
        logs_dir: Path,
        model_name: str | None = None,
        arvo_release: str | None = None,
        attention: str | None = None,
        agent_timeout_sec: float | None = None,
        max_turns: int | None = None,
        *args,
        **kwargs,
    ):
        super().__init__(logs_dir, model_name=model_name, *args, **kwargs)
        self._arvo_release_host = Path(
            arvo_release
            or os.environ.get("ARVO_RELEASE")
            or self._default_release_path()
        )
        # Treatment: constructor kwarg > ARVO_PROGRESSIVE_ATTENTION > default on
        attn = (
            attention
            if attention is not None
            else os.environ.get("ARVO_PROGRESSIVE_ATTENTION", "on")
        )
        self._attention = self._normalize_attention(attn)
        self._agent_timeout_sec = (
            int(agent_timeout_sec) if agent_timeout_sec is not None else None
        )
        self._max_turns = int(max_turns) if max_turns is not None else 25

    @staticmethod
    def _default_release_path() -> Path:
        # Monorepo default after `cd arvo && MIX_ENV=prod mix release arvo`
        repo = Path(__file__).resolve().parents[2]
        candidates = sorted(
            (repo / "arvo" / "_build" / "prod").glob("arvo-*.tar.gz"),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )
        if candidates:
            return candidates[0]
        return repo / "arvo" / "_build" / "prod" / "arvo-0.1.0.tar.gz"

    @staticmethod
    def _normalize_attention(value: str | int | bool | None) -> str:
        if value is True or value == 1:
            return "on"
        if value is False or value == 0:
            return "off"
        s = str(value or "on").strip().lower()
        if s in ("0", "off", "false", "no"):
            return "off"
        return "on"

    @staticmethod
    @override
    def name() -> str:
        return "arvo"

    @override
    def version(self) -> str | None:
        return "0.1.0"

    def _api_key(self) -> str | None:
        return self._extra_env.get("XAI_API_KEY") or os.environ.get("XAI_API_KEY")

    @override
    async def setup(self, environment: BaseEnvironment) -> None:
        host_release = self._arvo_release_host
        if not host_release.is_file():
            raise FileNotFoundError(
                f"Arvo release tarball not found at {host_release}. "
                "Build with: cd arvo && MIX_ENV=prod mix release arvo "
                "(sets ARVO_RELEASE to the tar.gz path if non-default)."
            )

        # Install release under /opt/arvo (KTD-D1). Upload tar, extract as root.
        await environment.exec(command="mkdir -p /opt/arvo /tmp/arvo-release", user="root")
        await environment.upload_file(
            source_path=host_release,
            target_path="/tmp/arvo-release/arvo.tar.gz",
        )
        extract = await environment.exec(
            command=(
                "rm -rf /opt/arvo/* && "
                "tar -xzf /tmp/arvo-release/arvo.tar.gz -C /opt/arvo && "
                "chmod -R a+rwX /opt/arvo && "
                "test -x /opt/arvo/bin/arvo-chat && "
                "ln -sfn /opt/arvo/bin/arvo-chat /usr/local/bin/arvo-chat && "
                "ln -sfn /opt/arvo/bin/arvo /usr/local/bin/arvo"
            ),
            user="root",
        )
        (self.logs_dir / "arvo-setup-extract.txt").write_text(
            f"exit={extract.return_code}\n"
            f"stdout:\n{extract.stdout or ''}\n"
            f"stderr:\n{extract.stderr or ''}\n"
            f"host_release={host_release}\n"
        )
        if extract.return_code != 0:
            raise RuntimeError(
                f"Arvo release extract failed (exit {extract.return_code})"
            )

        # Isolated HOME so sessions never touch host ~/.arvo
        await environment.exec(
            command=(
                "mkdir -p /home/agent/.arvo/sessions "
                "&& chmod -R 777 /home/agent"
            ),
            user="root",
        )

        if self._api_key():
            (self.logs_dir / "auth-mode.txt").write_text("XAI_API_KEY\n")
        else:
            (self.logs_dir / "auth-mode.txt").write_text("none\n")

        # Smoke: arvo-chat usage exits 1 without hang (no Focus).
        smoke = await environment.exec(
            command="/usr/local/bin/arvo-chat --help || true; "
            "test -x /opt/arvo/bin/arvo-chat",
            env={"HOME": "/home/agent", "ARVO_HEADLESS": "1"},
        )
        (self.logs_dir / "arvo-setup-status.txt").write_text(
            f"exit={smoke.return_code}\n"
            f"stdout:\n{smoke.stdout or ''}\n"
            f"stderr:\n{smoke.stderr or ''}\n"
            f"attention={self._attention}\n"
        )
        if smoke.return_code != 0:
            raise RuntimeError(
                f"arvo-chat not executable after install (exit {smoke.return_code})"
            )

    @override
    async def run(
        self,
        instruction: str,
        environment: BaseEnvironment,
        context: AgentContext,
    ) -> None:
        key = self._api_key()
        if not key:
            raise RuntimeError(
                "No credentials: set XAI_API_KEY "
                "(harbor run --ae XAI_API_KEY) for Arvo agent trials."
            )

        # Upload prompt file so multi-line instruction stays out of fragile argv.
        prompt_path = "/home/agent/harbor-instruction.md"
        prompt_host = self.logs_dir / "harbor-instruction.md"
        prompt_host.write_text(
            instruction if instruction.endswith("\n") else instruction + "\n"
        )
        await environment.exec(command="mkdir -p /home/agent", user="root")
        await environment.upload_file(
            source_path=prompt_host,
            target_path=prompt_path,
        )
        await environment.exec(
            command=f"chmod 644 {shlex.quote(prompt_path)}",
            user="root",
        )

        attn_env = "1" if self._attention == "on" else "0"
        model_env: dict[str, str] = {
            "HOME": "/home/agent",
            "PATH": "/usr/local/bin:/opt/arvo/bin:/usr/bin:/bin",
            "ARVO_HEADLESS": "1",
            "ARVO_MODE": "chat",
            "ARVO_CWD": "/app",
            "ARVO_PROGRESSIVE_ATTENTION": attn_env,
            "XAI_API_KEY": key,
        }

        timeout = self._agent_timeout_sec
        timeout_arg = str(timeout if timeout is not None else 600)
        cmd = (
            f"/usr/local/bin/arvo-chat "
            f"--cwd /app "
            f"--prompt {shlex.quote(prompt_path)} "
            f"--attention {self._attention} "
            f"--max-turns {self._max_turns} "
            f"--timeout-sec {timeout_arg}"
        )

        result = await environment.exec(
            command=(
                f"set -o pipefail; {cmd} "
                f"> >(tee /logs/agent/arvo-stdout.txt) "
                f"2> >(tee /logs/agent/arvo-stderr.txt >&2)"
            ),
            cwd="/app",
            env=model_env,
            timeout_sec=timeout,
        )

        (self.logs_dir / "exit-code.txt").write_text(str(result.return_code))
        (self.logs_dir / "attention-treatment.txt").write_text(self._attention + "\n")
        stdout = result.stdout or ""
        stderr = result.stderr or ""
        (self.logs_dir / "arvo-stdout-host.txt").write_text(stdout)
        (self.logs_dir / "arvo-stderr-host.txt").write_text(stderr)

        context.metadata = {
            "agent": "arvo",
            "entrypoint": "arvo-chat",
            "exit_code": result.return_code,
            "attention": self._attention,
            "stdout_chars": len(stdout),
            "stderr_chars": len(stderr),
            "model": self.model_name,
            "release": str(self._arvo_release_host),
        }
        # Non-zero arvo-chat exit is a failed attempt (reward 0 via verifier), not always infra.
