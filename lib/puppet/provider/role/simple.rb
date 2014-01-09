require 'utils/oracle_access'
require 'simple_resource'

Puppet::Type.type(:role).provide(:simple) do
	include SimpleResource::Provider
	include Utils::OracleAccess

  desc "Manage an Oracle role in an Oracle Database via regular SQL"

  mk_resource_methods

end

