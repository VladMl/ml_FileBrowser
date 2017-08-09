
CREATE GLOBAL TEMPORARY TABLE dir_list(file_name VARCHAR2(4000), is_file INTEGER) ON COMMIT DELETE ROWS;


CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "DirectoryLister" AS import java.io.File;
import java.util.Arrays;
import java.sql.*;
public class DirectoryLister
{
  public static void getFileList(String idir, String sep)
  throws SQLException
  {
    File aDirectory = new File(idir);
    File[] filesInDir = aDirectory.listFiles();
    String result = "";
    String file_name;
    int is_file;
    Connection conn = DriverManager.getConnection("jdbc:default:connection:");
    String sql = "INSERT INTO dir_list (file_name, is_file) VALUES (?, ?)";
    
    for ( int i=0; i<filesInDir.length; i++ )
    {
     file_name = filesInDir[i].getName();
     is_file = 0;
     if (filesInDir[i].isFile())
        is_file = 1;
     PreparedStatement pstmt = conn.prepareStatement(sql);
     pstmt.setString(1, file_name);
     pstmt.setLong(2, is_file);
     

     pstmt.executeUpdate();
     pstmt.close();
    }
  }
};
/


CREATE OR REPLACE PROCEDURE dirlist
(p_dir IN VARCHAR2, p_sep IN VARCHAR2)
AS LANGUAGE JAVA NAME
'DirectoryLister.getFileList
  (java.lang.String, java.lang.String)
  ';
/


CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "GetMimeType" AS
import javax.activation.MimetypesFileTypeMap;
public class GetMimeType
{
  public static String getType(String fileName)
 
  {
  MimetypesFileTypeMap mimeTypesMap = new MimetypesFileTypeMap();
  
  mimeTypesMap.addMimeTypes("application/msword doc DOC");
        mimeTypesMap.addMimeTypes("application/vnd.ms-excel xls XLS");
        mimeTypesMap.addMimeTypes("application/pdf pdf PDF");
        mimeTypesMap.addMimeTypes("text/xml xml XML");
        mimeTypesMap.addMimeTypes("text/html html htm HTML HTM");
        mimeTypesMap.addMimeTypes("text/plain txt text TXT TEXT");
        mimeTypesMap.addMimeTypes("image/gif gif GIF");
        mimeTypesMap.addMimeTypes("image/ief ief");
        mimeTypesMap.addMimeTypes("image/jpeg jpeg jpg jpe JPG");
        mimeTypesMap.addMimeTypes("image/tiff tiff tif");
        mimeTypesMap.addMimeTypes("image/png png PNG");
        mimeTypesMap.addMimeTypes("image/x-xwindowdump xwd");
        mimeTypesMap.addMimeTypes("application/postscript ai eps ps");
        mimeTypesMap.addMimeTypes("application/rtf rtf");
        mimeTypesMap.addMimeTypes("application/x-tex tex");
        mimeTypesMap.addMimeTypes("application/x-texinfo texinfo texi");
        mimeTypesMap.addMimeTypes("application/x-troff t tr roff");
        mimeTypesMap.addMimeTypes("audio/basic au");
        mimeTypesMap.addMimeTypes("audio/midi midi mid");
        mimeTypesMap.addMimeTypes("audio/x-aifc aifc");
        mimeTypesMap.addMimeTypes("audio/x-aiff aif aiff");
        mimeTypesMap.addMimeTypes("audio/x-mpeg mpeg mpg");
        mimeTypesMap.addMimeTypes("audio/x-wav wav");
        mimeTypesMap.addMimeTypes("video/mpeg mpeg mpg mpe");
        mimeTypesMap.addMimeTypes("video/quicktime qt mov");
        mimeTypesMap.addMimeTypes("video/x-msvideo avi");
  
  String mimeType = mimeTypesMap.getContentType(fileName);
  
   return mimeType;
  }
};
/

CREATE OR REPLACE FUNCTION GetFileMimeType
(p_file_name IN VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA NAME
'GetMimeType.getType
  (java.lang.String) return java.lang.String  ';
/



CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "ReadFile" as import java.lang.*;
import java.io.*;
import java.sql.Blob;

public class FileAPI {
    public static String readFile(String path, Blob[] outLob) {
        FileInputStream fileStream = null;

        Reader reader = null;
        Blob tmp = outLob[0];
        OutputStream ous = null;
        String fileName;
        try {
            ous = tmp.setBinaryStream(1);


            fileStream = new FileInputStream(path);
            
            byte[] buffer = new byte[4096];
            int read = 0;
            while ((read = fileStream.read(buffer)) != -1) {
                ous.write(buffer, 0, read);
            }


            outLob[0] = tmp;
        } catch (Exception e) {
            return e.toString();
           
        } finally {
            try {
                if (fileStream != null) fileStream.close();
                if (ous != null) ous.close();
            } catch (IOException e) {}
        }
        return "success";
    }
}
/


CREATE OR REPLACE FUNCTION readFile (p_path IN VARCHAR2
    , p_outlob IN OUT NOCOPY BLOB
    )
RETURN VARCHAR2
AS LANGUAGE JAVA
NAME 'FileAPI.readFile(
        java.lang.String,
        java.sql.Blob[]) return java.lang.String';
/

create or replace package ml_file_browser
as

PROCEDURE get_file_list (p_path VARCHAR2);

PROCEDURE get_file(p_file_name varchar2);

end;
/


CREATE OR REPLACE PACKAGE ml_file_browser
AS
   PROCEDURE get_file_list (p_path VARCHAR2);

   PROCEDURE get_file (p_file_name VARCHAR2);
END;
/


CREATE OR REPLACE PACKAGE BODY ml_file_browser
AS
   PROCEDURE get_file_list (p_path VARCHAR2)
   IS
      lb_result BLOB;
      lv_str VARCHAR2 (32000) := '';
      lbl_first_line BOOLEAN := TRUE;
   BEGIN
      dirlist (p_path, ',');

      DBMS_LOB.createtemporary (lb_result, TRUE);

      DBMS_LOB.open (lb_result, DBMS_LOB.lob_readwrite);

      DBMS_LOB.append (lb_result,
                       UTL_RAW.cast_to_raw ('{"files": [' || CHR (10)));



      FOR files
         IN (  SELECT  file_name,
                      DECODE (is_file,
                              0, '_folder',
                              REGEXP_SUBSTR (file_name, '(\w+)(?:\.\w+)*$'))
                         file_ext,
                      is_file
                 FROM dir_list
             ORDER BY is_file, file_name)
      LOOP
         IF NOT lbl_first_line
         THEN
            DBMS_LOB.append (lb_result,
                             UTL_RAW.cast_to_raw (',' || CHR (10)));
         END IF;



         lv_str :=
               '{"file_name":"'
            || files.file_name
            || '", "file_ext":"'
            || files.file_ext
            || '", "is_file":"'
            || files.is_file
            || '"}';



         lbl_first_line := FALSE;



         DBMS_LOB.append (lb_result, UTL_RAW.cast_to_raw (lv_str));
      END LOOP;



      DBMS_LOB.append (lb_result, UTL_RAW.cast_to_raw (']}' || CHR (10)));

      HTP.p ('Content-Type: application/json; charset=UTF-8');

      WPG_DOCLOAD.download_file (lb_result);
   END;

   PROCEDURE get_file (p_file_name VARCHAR2)
   IS
      l_temp BLOB;
      l_res VARCHAR2 (1000);
      lv_characterset VARCHAR2 (1000);
      lv_mime_type VARCHAR2 (4000);
   BEGIN
      DBMS_LOB.CREATETEMPORARY (l_temp, TRUE);

      SELECT VALUE
        INTO lv_characterset
        FROM nls_database_parameters
       WHERE parameter = 'NLS_CHARACTERSET';

      l_res :=
         readFile (CONVERT (p_file_name, 'UTF8', 'CL8MSWIN1251'), l_temp);

      lv_mime_type := GetFileMimeType (p_file_name);
      HTP.p ('Content-Type: ' || lv_mime_type || '; charset=UTF-8');
      HTP.p (
            'Content-Disposition: inline; filename="'
         || REPLACE (p_file_name, REGEXP_SUBSTR (p_file_name, '.*\/'))
         || '";');
      WPG_DOCLOAD.download_file (l_temp);
   END;
END;
/


grant execute on ML_FILE_BROWSER to APEX_PUBLIC_USER;