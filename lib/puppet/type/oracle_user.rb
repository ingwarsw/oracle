require 'simple_resource'
require 'utils/oracle_access'

module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the SqlResource provider
  #
  newtype(:oracle_user) do
    include SimpleResource
    include Utils::OracleAccess

    desc %q{
      This resource allows you to manage a user in an Oracle database.
    }

    ensurable

    set_command(:sql)


    to_get_raw_resources do
      sql "select * from dba_users"
    end

    on_create do
      "create user #{self[:name]}"
    end

    on_modify do
      "alter user #{self[:name]}"
    end

    on_destroy do
      "drop user #{self[:name]}"
    end

    newparam(:name) do
      include SimpleResource
      include SimpleResource::Validators::Name
      include SimpleResource::Mungers::Upcase

      desc "The user name"

      isnamevar

      to_translate_to_resource do | raw_resource|
        raw_resource['USERNAME'].upcase
      end


    end

    newproperty(:user_id) do
      include SimpleResource

      include SimpleResource::Validators::Integer
      include SimpleResource::Mungers::Integer

      desc "The user id"

      to_translate_to_resource do | raw_resource|
        raw_resource['USER_ID'].to_i
      end

    end

    newproperty(:password) do
      include SimpleResource
      include SimpleResource::Validators::Name

      desc "The user's password"
      defaultto 'password'

      to_translate_to_resource do | raw_resource|
        raw_resource['PASSWORD']
      end

      on_apply do
        "identified by #{resource[:password]}"
      end

    end

    newproperty(:default_tablespace) do
      include SimpleResource
      include SimpleResource::Validators::Name
      include SimpleResource::Mungers::Upcase

      desc "The user's default tablespace"
      defaultto 'USERS'

      to_translate_to_resource do | raw_resource|
        raw_resource['DEFAULT_TABLESPACE'].upcase
      end

      on_apply do
        "default tablespace #{resource[:default_tablespace]}"
      end

    end

    newproperty(:temporary_tablespace) do
      include SimpleResource
      include SimpleResource::Validators::Name
      include SimpleResource::Mungers::Upcase

      desc "The user's temporary tablespace"
      defaultto 'TEMP'

      to_translate_to_resource do | raw_resource|
        raw_resource['TEMPORARY_TABLESPACE'].upcase
      end


      on_apply do
        "temporary tablespace #{resource[:temporary_tablespace]}"
      end

    end

  end
end
