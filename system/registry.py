# ~/system/registry.py

import os
import threading
import inspect
import importlib.util
from typing import Callable

class TypeRegistry:
  """
  assigns unique int codes and stores a factory per code
  """
  def __init__(self):
    self._next_code = 1
    self._name_to_code: dict[str,int] = {}
    self._code_to_factory: dict[int,Callable] = {}

  def register_type(self, name: str, factory: Callable) -> int:
    """
    Assign a new integer code to `name` and store its factory.
    Raises if name already registered.
    """
    if name in self._name_to_code:
      raise ValueError(f"Type '{name}' already registered")

    code = self._next_code
    self._next_code += 1
    self._name_to_code[name] = code
    self._code_to_factory[code] = factory

    return code

  def get_code(self, name: str) -> int | None:
    return self._name_to_code.get(name)

  def create(self, code: int, *args, **kwargs):
    """
    Call the factory registered under `code`, forwarding args/kwargs.
    """
    factory = self._code_to_factory.get(code)
    if factory is None:
      raise KeyError(f"No factory for type code {code}")

    return factory(*args, **kwargs)

from core.models import StructuralComponent, StructuralAnalysis

class CoreRegistry:
  """
  holds two TypeRegistries, one for the SCs, one for the SAs
  """
  def __init__(self):
    self.SCs = TypeRegistry()
    self.SAs  = TypeRegistry()

  def register_SC(self, name: str, factory: Callable) -> int:
    return self.SCs.register_type(name, factory)

  def register_SA(self, name: str, factory: Callable) -> int:
    return self.SAs.register_type(name, factory)

  def create_SC(self, code: int, *args, **kwargs):
    return self.SCs.create(code, *args, **kwargs)

  def create_SA(self, code: int, *args, **kwargs):
    return self.SAs.create(code, *args, **kwargs)

# Singleton instance for the whole app
registry = CoreRegistry()


# --- PluginManager: dynamically load plugins and auto-register their classes ---
def discover_and_register_plugins(plugin_root: str = "plugins") -> None:
  """
  For each plugin directory under plugin_root containing plugin.py,
  import it and automatically register any classes defined there that
  subclass either StructuralComponent or StructuralAnalysis.
  """
  for name in os.listdir(plugin_root):
    plugin_path = os.path.join(plugin_root, name, "plugin.py")
    if not os.path.isfile(plugin_path):
      continue

    # Dynamically import plugin module
    spec   = importlib.util.spec_from_file_location(name, plugin_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Inspect module for classes defined _in_ that module
    for _, cls in inspect.getmembers(module, inspect.isclass):
      if cls.__module__ != module.__name__:
        continue  # skip imports

      # Register based on base class
      if issubclass(cls, StructuralComponent):
        code = registry.register_SC(
          name=cls.__name__,
          factory=lambda *a, _cls=cls, **kw: _cls(*a, **kw)
        )
        print(f"[PluginManager] Registered Component {cls.__name__} → code {code}")
      elif issubclass(cls, StructuralAnalysis):
        code = registry.register_SA(
          name=cls.__name__,
          factory=lambda *a, _cls=cls, **kw: _cls(*a, **kw)
        )
        print(f"[PluginManager] Registered Analysis  {cls.__name__} → code {code}")
