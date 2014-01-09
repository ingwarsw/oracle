require 'simple_resource'
require 'utils/oracle_access'

module Puppet
  newtype(:tablespace) do
    include SimpleResource
    include Utils::OracleAccess

    include_file 'utils/ora'

    desc "This resource allows you to manage an Oracle tablespace."

    set_command(:sql)

    ensurable

    on_create do
      "create #{self.ts_type} tablespace \"#{self[:name]}\""
    end

    on_modify do
      "alter tablespace \"#{self[:name]}\""
    end

    on_destroy do
      "drop tablespace \"#{self[:name]}\" including contents and datafiles"
    end

    to_get_raw_resources do
      sql "select * from dba_tablespaces t, dba_data_files f where t.TABLESPACE_NAME = f.TABLESPACE_NAME"
    end

    newparam(:name) do
      include SimpleResource
      include SimpleResource::Validators::Name
      include SimpleResource::Mungers::Upcase
      desc "The tablespace name"

      isnamevar

      to_translate_to_resource do | raw_resource|
        raw_resource['TABLESPACE_NAME']
      end

    end

    newparam(:database) do
      include SimpleResource
      include SimpleResource::Validators::Name
      desc "The database name"
    end

    newproperty(:logging) do
      include SimpleResource

      desc "TODO: Add description"
      newvalues(:yes, :no)


      to_translate_to_resource do | raw_resource|
        case raw_resource['LOGGING']
        when 'LOGGING' then :yes
        when 'NOLOGGING' then :no
        else
          fail('Invalid Logging found in tablespace resource.')
        end
      end

      on_apply do
        if resource[:logging] == :yes
          "logging"
        end
      end

    end


    newproperty(:datafile) do
      include SimpleResource
      desc "The name of the datafile"

      on_apply do
        "datafile '#{resource[:datafile]}'"
      end

      to_translate_to_resource do | raw_resource|
        File.basename(raw_resource['FILE_NAME'])
      end

    end


    newproperty(:size) do
      include SimpleResource
      include SimpleResource::Mungers::Size

      desc "The size of the tablespace"
      defaultto "500M"

      on_apply do
        "size #{resource[:size]}"
      end

      to_translate_to_resource do | raw_resource|
        raw_resource['BYTES'].to_i
      end

    end


    newproperty(:autoextend) do
      include SimpleResource

      desc "Enable autoextension for the tablespace"
      newvalues(:on, :off)

      to_translate_to_resource do | raw_resource|
        case raw_resource['AUT']
        when 'YES' then :on
        when 'NO' then :no
        else
          fail('Invalid autoxtend found in tablespace resource.')
        end
      end

      on_apply do
        "autoextend #{resource[:autoextend]}"
      end
    end

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

    # TODO: Check values
    # newproperty(:max_size) do
    #   include ::Utils::Mungers::Size
    #   desc "maximum size for autoextending"

    #   to_translate_to_resource do | raw_resource|
    #     raw_resource['MAX_SIZE'].to_i
    #   end


    #   on_apply do
    #     "maxsize #{resource[:max_size]}"
    #   end

    # end


    newproperty(:extent_management) do
      include SimpleResource

      desc "TODO: Give description"
      newvalues(:local, :dictionary)

      to_translate_to_resource do | raw_resource|
        raw_resource['EXTENT_MAN'].downcase.to_sym
      end

      on_apply do
        "extent management #{resource[:extent_management]}"
      end

    end


    newproperty(:segment_space_management) do
      include SimpleResource

      desc "TODO: Give description"
      newvalues(:auto, :manual)

      to_translate_to_resource do | raw_resource|
        raw_resource['SEGMEN'].downcase.to_sym
      end

      on_apply do
        "segment space management #{resource[:segment_space_management]}"
      end

    end

    newproperty(:bigfile) do
      include SimpleResource

      desc "the type of datafile used for the tablespace"
      newvalues(:yes, :no)

      to_translate_to_resource do | raw_resource|
        raw_resource['BIG'].downcase.to_sym
      end
    end


    def ts_type
      if self['bigfile'] == :yes
        'bigfile'
      else
        'smallfile'
      end
    end


  end
end
