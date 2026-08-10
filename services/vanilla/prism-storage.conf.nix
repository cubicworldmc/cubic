{ lib, culib }:
''
  # When enabled, worlds are identified by name instead of UUID.
  # This is useful for servers with software that frequently regenerates worlds
  # where the world name stays the same but the UUID changes.
  # Disabled by default. Only enable if you have a specific need for this.
  identify-worlds-by-name=false
  # Enable query spy. This logs queries and helpful debug information.
  # Used primarily for development and debugging. Use carefully.
  spy=false
  # Set which storage system to use.
  # Available options: CLICKHOUSE, H2, MARIADB, MYSQL, POSTGRES, SQLITE
  # NOTE: Only one storage system may be used at a time.
  # Transferring data from one to another is not yet supported.
  primary-storage-type=CLICKHOUSE
  # Settings for clickhouse
  clickhouse {
      # Configure the hostname.
      host="@${lib.strings.toCamelCase (culib.serviceIpSecret "clickhouse-server-prism")}@"
      # Enter the password, if the selected datasource uses authentication.
      password="@mysqlPrismUserPass@"
      # Configure the port.
      port="@clickhouseTcpPort@"
      # Enter the username, if the selected datasource uses authentication.
      username=prism
      # Set the max number of records saved to storage per batch.
      batch-max=5000
      # Configure the database name.
      database=default
      # Enter the prefix prism should use for database table names. i.e. prism_activities.
      prefix="prism_"
  }
''
