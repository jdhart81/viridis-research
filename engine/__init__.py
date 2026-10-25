"""Viridis research engine v3.

Trusted code. Every module here runs on main's checkout in a trusted job
(plan, verify, decisions, weekly, watchdog) or in the research job before the
agent starts. Nothing in this package ever executes agent-supplied code
outside :mod:`engine.sandbox`.
"""

__version__ = "3.0.0"
