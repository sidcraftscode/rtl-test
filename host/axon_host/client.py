"""Submit DMA descriptors to the card through its command ring."""

from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import Protocol

log = logging.getLogger(__name__)


@dataclass(frozen=True)
class Descriptor:
    src_addr: int
    dst_addr: int
    length: int
    flags: int = 0


class CommandRing(Protocol):
    def push(self, desc: Descriptor) -> int:
        """Queue a descriptor and return its completion tag."""

    def wait(self, tag: int, timeout: float) -> int:
        """Block until `tag` completes; return bytes moved. Raises TimeoutError."""


class AxonClient:
    def __init__(self, ring: CommandRing, timeout_s: float = 0.5, retries: int = 3) -> None:
        self._ring = ring
        self.timeout_s = timeout_s
        self.retries = retries

    def submit(self, desc: Descriptor) -> int:
        """Run one transfer and return the number of bytes moved."""
        if desc.length <= 0 or desc.length % 4:
            raise ValueError("length must be a positive multiple of 4")
        for attempt in range(self.retries + 1):
            try:
                tag = self._ring.push(desc)
                return self._ring.wait(tag, timeout=self.timeout_s)
            except TimeoutError:
                log.warning("DMA submit timed out, retrying (%d)", attempt + 1)
        raise TimeoutError(f"transfer did not complete after {self.retries + 1} attempts")
