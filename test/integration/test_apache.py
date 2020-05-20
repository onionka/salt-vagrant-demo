import conftest


def test_apache_is_installed(host):
	apache = host.package("apache2")
	assert apache.is_installed
