package com.marklogic.sparql2xquery.example;

import java.io.File;
import java.io.InputStream;

import sw4j.util.Sw4jException;
import sw4j.util.ToolIO;

public class ToolDataLoader {


	public static String loadDataFromFile(String filename, String filepath) throws Sw4jException{
		File f = new File(filepath + filename);
		String data;
		data = ToolIO.pipeFileToString(f);
		return data;
	}
	
	public static InputStream prepareInputStreamFromFile(String filename, String filepath) throws Sw4jException{
		File f = new File(filepath + filename);
		return ToolIO.prepareFileInputStream(f);
	}
	
}
