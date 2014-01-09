require 'simple_resource'
require 'utils/oracle_access'

module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the SqlResource
  #
  newtype(:role) do
    include SimpleResource
    include ::Utils::OracleAccess

    desc "This resource allows you to manage a role in an Oracle database."

    set_command(:sql)

    ensurable

    to_get_raw_resources do
      sql "select * from dba_roles"
    end

    on_create do
    	"create role #{self[:name]}"
    end

    on_modify do
      "alter role#{self[:name]}"
    end

    on_destroy do
      "drop role#{self[:name]}"
    end

    newparam(:name) do
      include SimpleResource
      include SimpleResource::Validators::Name
      desc "The role name "

      isnamevar

      to_translate_to_resource do | raw_resource|
      	raw_resource['ROLE']
      end

    end

    newproperty(:password) do
      include SimpleResource
      desc "The password"

      to_translate_to_resource do | raw_resource|
        ''
      end

     on_apply do
        "identified by #{self[:password]}"
      end

    end


  end
end


