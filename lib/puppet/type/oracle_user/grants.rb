newproperty(:grants, :array_matching => :all) do
  include SimpleResource
  include Utils::OracleAccess

  desc "grants for this user"

  to_translate_to_resource do | raw_resource|
    user = raw_resource['USERNAME'].upcase
    privileges(user) + granted_roles(user)
  end

  #
  # because the order may differ, but they are still the same,
  # to decide if they are equal, first do a sort on is and should
  #
  def insync?(is)
    is.sort == should.sort
  end

  def change_to_s(from, to)
    return_value = []
    return_value << "revoked the #{revoked_rights} right(s)" unless revoked_rights.emtpy?
    return_value << "granted the #{granted_rights} right(s)" unless granted_rights.empty?
    return_value.join(' and ')
  end

  on_apply do | command_builder |
    command_builder.after(revoke(revoked_rights))
    command_builder.after(grants(granted_rights))
    nil
  end

  private

    def current_rights
    # TODO: Check why this needs to be so difficult
    resource.to_resource.to_hash.delete_if {|key, value| value == :absent}.fetch(:grants) { []}
    end

    def expected_rights
      resource.to_hash.fetch(:grants) {[]}
    end

    def revoked_rights
      current_rights - expected_rights
    end

    def granted_rights
      expected_rights - current_rights
    end

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
