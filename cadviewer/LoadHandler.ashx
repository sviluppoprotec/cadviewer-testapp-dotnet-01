﻿<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.Web;
using System.IO;
using System.Text;
using System.Configuration;


public class Handler : IHttpHandler {

    public void ProcessRequest (HttpContext context) {


        if (context.Request.HttpMethod.Equals("GET"))
        {
            DoGet(context);
        }
        if (context.Request.HttpMethod.Equals("POST"))
        {
            DoPost(context);
        }

    }


    private void DoPost(HttpContext context)
    {

        context.Response.ContentType = "text/plain";

        string ServerLocation = ConfigurationManager.AppSettings["ServerLocation"];
        string ServerUrl = ConfigurationManager.AppSettings["ServerUrl"];
        string AppLocation = ConfigurationManager.AppSettings["AppLocation"];

        string filePath = "";
        string loadtype = "";

        try{

            loadtype = context.Request["loadtype"];

            if ( loadtype!=null)
                loadtype = loadtype.Trim('/');
            

            filePath = context.Request["file"];
            
            if ( filePath!=null)
                filePath = filePath.Trim('/');
            

            if (loadtype == null || filePath == null){
                string myresponse = "";
                context.Response.Write(myresponse);
                return;
            }


            if (loadtype.IndexOf("languagefile") == 0)
            {
                filePath = AppLocation + filePath;
            }
          

            if (loadtype.IndexOf("menufile") == 0)
            {
                filePath = AppLocation + filePath;
            }

            if (loadtype.IndexOf("serverfilelist") == 0)
            {

                 if (filePath.IndexOf(ServerUrl) == 0)
                    {
                        //do nothing!! - handle below
                    }
                 else
                    filePath = ServerLocation + filePath;
            }

        }
        catch(Exception ee){
            Console.WriteLine(ee.Message);

        }


        if (filePath.IndexOf(ServerUrl) == 0)
        {
            filePath = ServerLocation + filePath.Substring(ServerUrl.Length);
        }



        try
        {

            string localPath = new Uri(filePath).LocalPath;

            //string localPath = new Uri(filePath).LocalPath;

            //context.Response.Write("localPath="+localPath);

            //if (true) return;

            using (FileStream fsSource = new FileStream(localPath, FileMode.Open, FileAccess.Read))
            {

                // Read the source file into a byte array.
                byte[] bytes = new byte[fsSource.Length];
                int numBytesToRead = (int)fsSource.Length;
                int numBytesRead = 0;
                while (numBytesToRead > 0)
                {
                    // Read may return anything from 0 to numBytesToRead.
                    int n = fsSource.Read(bytes, numBytesRead, numBytesToRead);

                    // Break when the end of the file is reached.
                    if (n == 0)
                        break;

                    numBytesRead += n;
                    numBytesToRead -= n;
                }
                numBytesToRead = bytes.Length;

                UTF8Encoding temp = new UTF8Encoding(true);

                context.Response.Write(temp.GetString(bytes));
                return;

            }
        }
        catch (FileNotFoundException ioEx)
        {
            context.Response.Write("FileNotFound"+ioEx);
            Console.WriteLine(ioEx.Message);
            return;
        }


       context.Response.Write("LoadHander - unspecified error");

    }


    private void DoGet(HttpContext context)
    {

        //context.Response.Write("Hello World GET");
       //        context.Response.Write("Hello World Get:"+context+"XXX");

        DoPost(context);

    }



    public bool IsReusable {
        get {
            return false;
        }
    }

}