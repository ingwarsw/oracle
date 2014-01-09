require 'simple_resource'

Puppet::Type.type(:grant).provide(:simple) do
	include SimpleResource::Provider
	include Utils::OracleAccess

  mk_resource_methods

end

