# Copyright (c) 2016 CEF Python, see the Authors file.
# All rights reserved. Licensed under BSD 3-clause license.
# Project website: https://github.com/cztomczak/cefpython

"""Run unit tests. With no arguments all tests are run. Read notes below.

Usage:
    _test_runner.py [--debug] [FILE | _TESTCASE]

Options:
    --debug    Enable debug info
    FILE       Run tests from single file
    _TESTCASE  Test cases matching pattern to run eg "file.TestCase".
               Calling with this argument is for internal use only.
               It has side effects, so don't use it. See comments.

Notes:
    - Files starting with "_" are ignored
    - If test case name contains "IsolatedTest" word then this test
      case will be run using a new instance of Python interpreter.
      In such case instead of calling "unittest.main()" use this code:
      "import _runner; _runner.main(os.path.basename(__file__))".
    - Tested only with TestCase objects. TestSuite usage is untested.
"""

import unittest
import os
import platform
import sys
from os.path import dirname, realpath
import re
import subprocess

# Command line args
CUSTOM_CMDLINE_ARG = ""


def main(file_arg=""):
    # type: (str) -> None
    """Main entry point."""

    # Set working dir to script's current
    os.chdir(dirname(realpath(__file__)))

    # Script arguments
    testcase_arg = ""
    if len(sys.argv) > 1 and sys.argv[1].startswith("--"):
        # Will allow to pass custom args like --debug to isolated tests
        # (main_test.py for example).
        global CUSTOM_CMDLINE_ARG
        CUSTOM_CMDLINE_ARG = sys.argv[1]
    elif len(sys.argv) > 1:
        if ".py" in sys.argv[1]:
            file_arg = sys.argv[1]
        else:
            testcase_arg = sys.argv[1]

    # Run tests
    runner = TestRunner()
    if testcase_arg:
        runner.run_testcase(testcase_arg)
    elif file_arg:
        runner.run_file(file_arg)
    else:
        runner.run_all()


class TestRunner(object):
    """Customized test runner."""

    ran = 0
    errors = 0
    failures = 0
    cefpython_version = "-unknown-"

    _suites = None  # type: unittest.TestSuite
    _isolated_suites = None  # type: unittest.TestSuite
    _import_errors = None  # type: unittest.TestSuite

    def _reset_state(self):
        # type: () -> None
        """Reset TestRunner state before test discovery."""
        self.ran = 0
        self.errors = 0
        self.failures = 0
        self._suites = unittest.TestSuite()
        self._isolated_suites = unittest.TestSuite()
        self._import_errors = unittest.TestSuite()

    # ---- Public methods

    def run_testcase(self, testcase):
        # type: (str) -> None
        """Run single test case eg 'foo.BarTest'. This is needed to
           run single testcase that is marked as IsolatedTest."""
        self._discover("[!_]*.py", testcase)
        assert not self._count_suites(self._isolated_suites)
        if not self._count_suites(self._suites):
            print("[_test_runner.py] ERROR: test case not found")
            sys.exit(1)
        # Import errors found during discovery are ignored
        self._run_suites(self._suites)
        self._exit()

    def run_file(self, filename):
        # type: (str) -> None
        """Run test cases from a specific file. This is needed so that
           you can use _runner.main() in isolated tests."""
        self._discover(filename)
        self._run_discovered_suites()

    def run_all(self):
        # type: () -> None
        """Run all tests from current directory."""
        self._discover("[!_]*.py")
        self._run_discovered_suites()

    # ---- Private methods

    def _run_discovered_suites(self):
        # type: () -> None
        """Run both normal and isolated suites."""
        suites = self._merge_suites(self._import_errors, self._suites)
        self._run_suites(suites)
        self._run_suites_in_isolation(self._isolated_suites)
        self._print_summary()

    def _run_suites(self, suites):
        # type: (unittest.TestSuite) -> None
        """Run suites."""
        if not self._count_suites(suites):
            return
        runner = unittest.TextTestRunner(verbosity=2, descriptions=True,
                                         buffer=False)
        # Update "ran" before running suites, because after ran
        # counting them doesn't work (Python 3 issue).
        self.ran += self._count_suites(suites)
        result = runner.run(suites)
        self.errors += len(result.errors)
        self.failures += len(result.failures)

    def _run_suites_in_isolation(self, suites):
        # type: (unittest.TestSuite) -> None
        """Run each suite using new instance of Python interpreter."""
        if not self._count_suites(suites):
            return
        for suite in suites:
            # Find test case identifier
            testcase_id = ""
            for testcase in suite:
                testcase_id = testcase.id()
                break
            # Run test using new instance of Python interpreter
            try:
                output = subprocess.check_output(
                        [sys.executable, "_test_runner.py", testcase_id,
                         CUSTOM_CMDLINE_ARG],
                        stderr=subprocess.STDOUT)
                exit_code = 0
            except subprocess.CalledProcessError as exc:
                output = exc.output
                exit_code = exc.returncode
            if type(output) != str:
                output = output.decode("utf-8", errors="replace")
            # Fetch number of sub-tests ran from output
            match = re.search(r"^Ran (\d+) sub-tests in \w+", output,
                              re.MULTILINE)
            if match:
                self.ran += int(match.group(1))
            # Fetch CEF Python version from output
            match = re.search(r"^CEF Python (\d+\.\d+)", output,
                              re.MULTILINE)
            if match:
                self.cefpython_version = match.group(1)
            # Write original output
            sys.stdout.write(output)
            # If tests failed parse output for errors/failures
            if exit_code:
                if output:
                    lines = output.splitlines()
                    lastline = lines[len(lines)-1]
                    match = re.search(r"failures=(\d+)", lastline)
                    if match:
                        self.failures += int(match.group(1))
                    match = re.search(r"errors=(\d+)", lastline)
                    if match:
                        self.errors += int(match.group(1))
                if not self.errors and not self.failures:
                    self.errors += 1
            elif output:
                # Test case still might have failed and unittest would not
                # detect this. For example when assertion fails
                # in ClientHandler in core_test.py .
                if "Traceback (most recent call last)" in output\
                        or "AssertionError" in output:
                    self.errors += 1

        # Update ran
        self.ran += self._count_suites(suites)

    def _count_suites(self, suites):
        # type: (unittest.TestSuite) -> int
        count = 0
        for suite in suites:
            if isinstance(suite, unittest.TestSuite):
                for _ in suite:
                    count += 1
        return count

    def _merge_suites(self, suites1, suites2):
        # type: (unittest.TestSuite, unittest.TestSuite) -> unittest.TestSuite
        merged = unittest.TestSuite()
        for suite in suites1:
            merged.addTest(suite)
        for suite in suites2:
            merged.addTest(suite)
        return merged

    def _discover(self, pattern, testcase_name=""):
        # type: (str, str) -> None
        """Test discovery using glob pattern from arg or main()."""
        self._reset_state()
        loader = unittest.TestLoader()
        discovered_suite = loader.discover(start_dir=".", pattern=pattern)
        for level1_suite in discovered_suite:
            for level2_suite in level1_suite:
                if isinstance(level2_suite, unittest.TestSuite):
                    for testcase_obj in level2_suite:
                        if testcase_name:
                            if re.match(re.escape(testcase_name),
                                        testcase_obj.id()):
                                self._suites.addTest(level2_suite)
                            break
                        elif "IsolatedTest" in testcase_obj.id():
                            self._isolated_suites.addTest(level2_suite)
                            break
                        else:
                            self._suites.addTest(level2_suite)
                            break
                elif not testcase_name:
                    # unittest.loader.ModuleImportFailure
                    # Warning: If there is an import error in a file
                    # containing a test case that is being run then there
                    # won't be any error displayed about it when running
                    # that single test case. However running a single test
                    # case is for internal use only, to run test cases in
                    # isolation with a new instance of Python interpreter.
                    # Import errors will always be showed when running all
                    # tests or tests from file.
                    self._import_errors.addTest(level2_suite)

    def _print_summary(self):
        # type: () -> None
        """Print summary and exit."""
        print("-"*70)
        print("[_test_runner.py] CEF Python {ver}"
              .format(ver=self.cefpython_version))
        print("[_test_runner.py] Python {ver} {arch}"
              .format(ver=platform.python_version(),
                      arch=platform.architecture()[0]))
        print("[_test_runner.py] Ran {ran} tests in total"
              .format(ran=self.ran))
        if self.errors or self.failures:
            failed_str = "[_test_runner.py] FAILED ("
            if self.failures:
                failed_str += ("failures="+str(self.failures))
            if self.errors:
                if self.failures:
                    failed_str += ", "
                failed_str += ("errors="+str(self.errors))
            failed_str += ")"
            print(failed_str)
        else:
            print("[_test_runner.py] OK all unit tests succeeded")
        self._exit()

    def _exit(self):
        # type: () -> None
        """Exit with appropriate exit code."""
        if self.errors or self.failures:
            sys.exit(1)
        else:
            sys.exit(0)

if __name__ == "__main__":
    main()
