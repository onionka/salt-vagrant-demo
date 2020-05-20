def dict_to_yaml(value, indent=1, acc="", tab_spaces=4):
	"""Converts standard python's dict value to the YAML

	:param value: The input dictionary value that will be converted to YAML
	:param indent: The initial intendation for resulting yaml
	:param acc: The result accumulator used for recursive conversion
	:returns: The resulting YAML string
	"""
    for key, value in d.iteritems():
        acc += " " * indent * tab_spaces + str(key)
        if isinstance(value, dict):
            acc = dict_to_yaml(value, indent + 1, acc + "\n")
        else:
            acc += ": " + str(value) + "\n"
    return acc
