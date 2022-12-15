package common.util;

import java.text.NumberFormat;
import java.util.Locale;

public class NumberUtil {
	
	public static void main(String args[]) throws NumberFormatException {

		// The number to format
		double number = 12345.678;

		// Get formatters for default, Spanish, and Japanese locales
		NumberFormat defaultFormat = NumberFormat.getInstance();
		NumberFormat spanishFormat = NumberFormat.getInstance(new Locale("es", "ES"));
		NumberFormat japaneseFormat = NumberFormat.getInstance(Locale.JAPAN);

		// Print out number in the default, Spanish, and Japanese formats
		// (Note: NumberFormat is not necessary for the default format)
		System.out.println("The number formatted for the default locale; " + defaultFormat.format(number));
		System.out.println("The number formatted for the Spanish locale; " + spanishFormat.format(number));
		System.out.println("The number formatted for the Japanese locale; " + japaneseFormat.format(number));
	}
	
	
}