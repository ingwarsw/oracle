newparam(:name) do
  include SimpleResource
  include SimpleResource::Validators::Name
  desc "The role name "

  isnamevar

  to_translate_to_resource do | raw_resource|
  	raw_resource['ROLE']
  end

end
