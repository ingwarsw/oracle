require 'simple_resource'
require 'utils/oracle_access'

module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the SqlResource
  #
  newtype(:grant) do
    include SimpleResource
    include ::Utils::OracleAccess

    desc "This resource allows you to manage a grant in an Oracle database."

    set_command(:sql)


    to_get_raw_resources do
    	grants = users.collect do | user |
	    	{ :username => user, :grants => privileges(user) + granted_roles(user)}
    	end
    	remove_users_without_grants(grants)
    end

    on_create do
    	"grant #{self[:grants].join('s')} to #{self[:name]}"
    end

    on_modify do
    	"revoke all privileges from #{self[:name]}; grant #{self[:grants].join(',')} to #{self[:name]};"
    	"grant #{self[:grants].join(',')} to #{self[:name]}"
    end

    on_destroy do
    	"revoke all privileges from #{self[:name]}"
    end

    newparam(:name) do
      include SimpleResource
      include SimpleResource::Validators::Name
      desc "The user name for the rights"

      isnamevar

      to_translate_to_resource do | raw_resource|
      	raw_resource[:username]
      end

    end

    newproperty(:grants, :array_matching => :all) do
      include SimpleResource
    	include SimpleResource::Mungers::Upcase
      desc "The right(s) to grant"

      to_translate_to_resource do | raw_resource|
      	raw_resource[:grants]
      end

    end

    private

    def self.remove_users_without_grants(grants)
    	grants.reject {| grant| grant[:grants] == []}
    end

    def self.privileges(user)
    	(sql "select distinct privilege from dba_sys_privs where grantee = '#{user}'").collect{|u| u['PRIVILEGE']}
    end

    def self.granted_roles(user)
   		(sql "select distinct granted_role from dba_role_privs where grantee = '#{user}'").collect{|u| u['GRANTED_ROLE']}
    end

    def self.users
   		(sql "select distinct username from dba_users").collect{|u| u['USERNAME']}
    end


  end
end


