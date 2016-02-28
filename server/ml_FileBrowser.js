     /* micoAjax 
      */
     function microAjax(B, A) {
         this.bindFunction = function(E, D) {
             return function() {
                 return E.apply(D, [D])
             }
         };
         this.stateChange = function(D) {
             if (this.request.readyState == 4) {
                 this.callbackFunction(this.request.responseText)
             }
         };
         this.getRequest = function() {
             if (window.ActiveXObject) {
                 return new ActiveXObject("Microsoft.XMLHTTP")
             } else {
                 if (window.XMLHttpRequest) {
                     return new XMLHttpRequest()
                 }
             }
             return false
         };
         this.postBody = (arguments[2] || "");
         this.callbackFunction = A;
         this.url = B;
         this.request = this.getRequest();
         if (this.request) {
             var C = this.request;
             C.onreadystatechange = this.bindFunction(this.stateChange, this);
             if (this.postBody !== "") {
                 C.open("POST", B, true);
                 C.setRequestHeader("X-Requested-With", "XMLHttpRequest");
                 C.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                 C.setRequestHeader("Connection", "close")
             } else {
                 C.open("GET", B, true)
             }
             C.send(this.postBody)
         }
     };


     var directory = {};
     directory.name = "Home";
     directory.dirpath = rootPath;

     var path = [];
     path[0] = directory;



     var itemTmpl = '<li class="t-Cards-item "><div class="t-Card"><a href="javascript:clickItem(FILE_NAME_FUNC, FILE_EXT_FUNC, IS_FILE)" class="t-Card-wrap">\
                       <div class="t-Card-icon"><span class="t-Icon "><span class="t-Card-initials" role="presentation"></span></span></div>\
                       <div class="t-Card-titleWrap"><h3 class="t-Card-title"> <img src="	' + imgPath + 'FILE_EXT.png"  onerror="this.src=\'' + imgPath + '_blank.png\'"  height="64" width="64" ><br>\
                       FILE_NAME</h3></div></a></div></li>';


     function getFiles(path) {
         document.getElementById('ml-files').innerHTML = '';
         refreshBreadcrumb();

         wp = apex.widget.waitPopup();

         microAjax(schema+".ml_file_browser.get_file_list?p_path=" + path, function(jFiles) {


             dataObj = JSON.parse(jFiles);


             var i = dataObj.files.length;
             html = '';

             htmlStart = '<ul class="t-Cards   t-Cards--featured t-Cards--5cols">';

             while (i--) {
                 currItemTmpl = itemTmpl.replace(/FILE_NAME_FUNC/g, String.fromCharCode(39) + dataObj.files[i].file_name + String.fromCharCode(39));
                 currItemTmpl = currItemTmpl.replace(/FILE_EXT_FUNC/g, String.fromCharCode(39) + dataObj.files[i].file_ext + String.fromCharCode(39));
                 currItemTmpl = currItemTmpl.replace(/FILE_NAME/g, dataObj.files[i].file_name);
                 currItemTmpl = currItemTmpl.replace(/FILE_EXT/g, dataObj.files[i].file_ext);
                 currItemTmpl = currItemTmpl.replace(/IS_FILE/g, dataObj.files[i].is_file);

                 html = currItemTmpl + html;


             }
             html = htmlStart + html + '</ul>';
             document.getElementById('ml-files').innerHTML = html;
             wp.remove();

         });


     }



     function clickItem(filename, fileext, isFile) {
         if (isFile == 0) {
             path.push({
                 name: filename,
                 dirpath: path[path.length - 1].dirpath + '/' + filename
             });
             getFiles(path[path.length - 1].dirpath);
         } else {
             var anchor = document.createElement('a');
             anchor.setAttribute('href', schema+".ml_file_browser.get_file?p_file_name=" + path[path.length - 1].dirpath + '/' + filename + '.' + fileext);
             
             var ev = document.createEvent("MouseEvents");
             ev.initMouseEvent("click", true, false, self, 0, 0, 0, 0, 0, false, false, false, false, 0, null);

             anchor.dispatchEvent(ev);
             anchor.remove();


         }
     }


     function clickBreadcrumbItem(id) {
         i = path.length;
         while (i--) {
             path.pop();
             if (i == id + 1)
                 break;
         }
         getFiles(path[id].dirpath);
     }




     function refreshBreadcrumb() {
         bhtml = '';

         i = path.length;
         while (i--) {
             if (i == path.length)
                 bhtml = '<li class="t-Breadcrumb-item is-active"><span class="t-Breadcrumb-label">' + path[0].name + '</span></li>' + bhtml;
             else
                 bhtml = '<li class="t-Breadcrumb-item"><a href="javascript:clickBreadcrumbItem(' + i + ')" class="t-Breadcrumb-label">' + path[i].name + '</a></li>' + bhtml;

         }

         document.getElementById('ml-filebrowser-breadcrumb').innerHTML = '<ul class="t-Breadcrumb  ">' + bhtml + '</ul>';
     }