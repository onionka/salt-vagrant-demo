Test vim installed:
  module_and_function: pkg.version
  args:
    - vim
  assertion: assertNotEmpty

Test tree installed:
  module_and_function: pkg.version
  args:
    - tree
  assertion: assertNotEmpty
