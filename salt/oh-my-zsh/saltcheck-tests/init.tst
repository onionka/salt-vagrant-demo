{% set users = salt.pillar.get("users") %}
{% for username, user in users.items() %}
{% set user_home_folder = "/home/" + username %}
Test {{ user_home_folder }}/.zshrc exists:
  module_and_function: cmd.run
  args:
    - cat {{ user_home_folder }}/.zshrc
  assertion: assertNotEmpty
  print_result: True
  output_details: True

Test {{ user_home_folder }}/.oh-my-zsh exists:
  module_and_function: cmd.run
  args:
    - ls {{ user_home_folder }}/.oh-my-zsh
  assertion: assertNotIn
  expected_return: "No such file or directory"
  print_result: True
  output_details: True

{% endfor %}