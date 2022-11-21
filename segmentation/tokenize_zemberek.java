package zemberek1;

import _zem.com.google.common.base.Joiner;
import java.util.Iterator;
import java.util.List;
import zemberek.core.logging.Log;
import zemberek.tokenization.TurkishTokenizer;
import zemberek.tokenization.Token;
import java.io.*;  
/**
 *
 * @author zeppy
 */
public class Zemberek1 {

  static TurkishTokenizer tokenizer = TurkishTokenizer.DEFAULT;

  public static void tokenIterator() {
    System.out.println("Low level tokenization iterator using Ant-lr Lexer.");
    String input = "İstanbul'a, merhaba!";
    System.out.println("Input = " + input);
    Iterator<Token> tokenIterator = tokenizer.getTokenIterator(input);
    while (tokenIterator.hasNext()) {
      Token token = tokenIterator.next();
      System.out.println(token);
    }
  }

  public static String simpleTokenization(String input) {
    TurkishTokenizer tokenizer = TurkishTokenizer.DEFAULT;
    String output = Joiner.on(" ").join(tokenizer.tokenizeToStrings(input));
    return output;
  }

  public static void customTokenizer() {
    TurkishTokenizer tokenizer = TurkishTokenizer
        .builder()
        .ignoreTypes(Token.Type.Punctuation, Token.Type.NewLine, Token.Type.SpaceTab)
        .build();
    List<Token> tokens = tokenizer.tokenize("Saat, 12:00.");
    for (Token token : tokens) {
      System.out.println(token);
    }
  }

  public static void main(String[] args) {

     try  
    {  
        File file=new File("newstest2017.tr");
        FileReader fr=new FileReader(file);   //reads the file  
        BufferedReader br=new BufferedReader(fr);  //creates a buffering character input stream  
        StringBuffer sb=new StringBuffer();    //constructs a string buffer with no characters  
        String line;  

        FileWriter outfile = new FileWriter("newstest2017.zb.tr");
        
        while((line=br.readLine())!=null)  
        {  
            String output = simpleTokenization(line);  
            outfile.write(output + "\n");
        }  
        fr.close();    //closes the stream and release the resources  
        outfile.close();
    }  
    catch(IOException e)  
    {  
        e.printStackTrace();  
    }  
    
  }
}
