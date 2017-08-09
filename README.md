#Oracle APEX Region Plugin - File Browser


##Changelog<br />
####1.0.0 - Initial Release<br />
####1.1.0 - Compatibility 12c and Apex 5.1.2<br />

##Install
- Run the database script "db.sql" from source directory.
- Import the plugin file "region_type_plugin_ml_filebrowser.sql" from source directory into your application
- Upload files from "server" directory into "Static application files"
- Run the command under SYSDBA user<br />
  exec dbms_java.grant_permission( '<OWNER>', 'SYS:java.io.FilePermission', '<<ALL FILES>>', 'read');
- ORDS<br />
  Remove requestValidationFunction value from the file default.xml<br />
  <entry key="security.requestValidationFunction"></entry>
- Upload icons (for example https://github.com/teambox/Free-file-icons  48px) through Static Application Files.


##Plugin Settings
- **Directory** - Absolute path to initial directory on your database server.

##Plugin Events


##Preview
![](https://raw.githubusercontent.com/VladMl/ml_FileBrowser/master/preview.png)
---
