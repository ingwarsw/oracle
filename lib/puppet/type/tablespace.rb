require 'easy_type'
require 'utils/oracle_access'

module Puppet
  newtype(:tablespace) do
    include EasyType
    include Utils::OracleAccess

    desc "This resource allows you to manage an Oracle tablespace."

    set_command(:sql)

    ensurable

    on_create do
      "create #{ts_type} tablespace \"#{name}\""
    end

    on_modify do
      "alter tablespace \"#{name}\""
    end

    on_destroy do
      "drop tablespace \"#{name}\" including contents and datafiles"
    end

    to_get_raw_resources do
      sql %q{select 
        t.tablespace_name,
        logging,
        extent_management,
        segment_space_management,
        bigfile,
        file_name,
        increment_by,
        autoextensible,
        bytes,
        to_char(maxbytes, '9999999999999999999') "MAX_SIZE"
      from 
        dba_tablespaces t, 
        dba_data_files f 
      where
        t.tablespace_name = f.tablespace_name
      }
    end

    parameter :name
    parameter :database
    property :logging
    property :datafile
    property :size
    property :autoextend
    property :next
    property :max_size
    property :extent_management
    property :segment_space_management
    property :bigfile


    def ts_type
      if self['bigfile'] == :yes
        'bigfile'
      else
        'smallfile'
      end
    end


  end
end
