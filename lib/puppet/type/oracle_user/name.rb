newparam(:name) do
  include EasyType
  include EasyType::Validators::Name
  include EasyType::Mungers::Upcase

  desc "The user name"

  isnamevar

  to_translate_to_resource do | raw_resource|
    raw_resource['USERNAME'].upcase
  end


end
