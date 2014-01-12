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
