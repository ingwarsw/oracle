newproperty(:grants, :array_matching => :all) do
  include SimpleResource
  include Utils::OracleAccess

  desc "grants for this user"

  to_translate_to_resource do | raw_resource|
    user = raw_resource['USERNAME'].upcase
    privileges(user) + granted_roles(user)
  end


  on_apply do | command_builder |
    # TODO: Check why this needs to be so difficult
    current_value = resource.to_resource.to_hash.delete_if {|key, value| value == :absent}.fetch(:grants) { []}
    expected_value = resource.to_hash.fetch(:grants) {[]}
    revoked_rights = current_value - expected_value
    granted_rights = expected_value - current_value
    command_builder.after(revoke(revoked_rights))
    command_builder.after(grants(granted_rights))
    nil
  end

  private

    def revoke(rights)
      rights.empty? ? nil : "revoke #{rights.join(',')} from #{provider.name}"
    end

    def grants(rights)
      rights.empty? ? nil : "grant #{rights.join(',')} to #{provider.name}"
    end

    def self.privileges(user)
      (sql "select distinct privilege from dba_sys_privs where grantee = '#{user}'").collect{|u| u['PRIVILEGE']}
    end

    def self.granted_roles(user)
      (sql "select distinct granted_role from dba_role_privs where grantee = '#{user}'").collect{|u| u['GRANTED_ROLE']}
    end

end
