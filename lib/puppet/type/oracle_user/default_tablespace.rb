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
