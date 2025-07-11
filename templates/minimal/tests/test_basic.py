"""Basic test file"""
import pytest


def test_basic():
    """Basic test function"""
    assert True


def test_import():
    """Test package import"""
    import src.your_package
    assert hasattr(src.your_package, '__version__')