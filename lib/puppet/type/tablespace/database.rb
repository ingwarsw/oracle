newparam(:database) do
  include EasyType
  include EasyType::Validators::Name
  desc "The database name"
end
