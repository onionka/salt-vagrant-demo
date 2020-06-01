Test apache installed:
  module_and_function: pkg.version
  args:
    - apache2
  assertion: assertNotEmpty
  print_result: True
  output_details: True

Test index.html present:
  module_and_function: cmd.run
  args:
    - ls /var/www/html/{{ salt['pillar.get']('domain') }}/public_html/
  assertion: assertIn
  expected_return: index.html
  print_result: True
  output_details: True

Test index.html served:
  module_and_function: http.query
  args:
    - "http://192.168.50.12:80/"
  assertion: assertIn
  assertion_section: body
  expected_return: "Apache-Salt Demo Web"
  print_result: True
  output_details: True
