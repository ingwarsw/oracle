# TODO: Check values
# newproperty(:next) do
#   include ::Utils::Mungers::Size
#   desc "Size of the next autoextent"

#   to_translate_to_resource do | raw_resource|
#     raw_resource['NEXT_EXTEN'].to_i
#   end

#   on_apply do
#     "next #{resource[:next]}"
#   end
# end