import com.sun.javadoc.AnnotationDesc;
import com.sun.javadoc.ClassDoc;
import com.sun.javadoc.Doclet;
import com.sun.javadoc.LanguageVersion;
import com.sun.javadoc.MethodDoc;
import com.sun.javadoc.PackageDoc;
import com.sun.javadoc.RootDoc;
import com.sun.javadoc.Type;

/**
 * <p>
 * A doclet that checks for the presence of Override annotations that have been applied to interface implementations.
 * </p>
 * 
 * <p>
 * Every class in every specified package is analyzed irrespective of the filtering imposed by the doclet parametes.
 * A line starting "ERROR" is output to stdout for every instance discovered. It may occur(?) that javadoc doesn't
 * have enough information to determine, one way or another, whether a method is a genuine override or simply an
 * implementation. In this case a "WARNING" is output.
 * </p>
 * 
 * <p>
 * A debug flag ("-debug") can be specified when executing this doclet via javadoc. This will output every package,
 * class, method and annotation considered.
 * </p>
 * 
 * @author Tom Gibara
 *
 */

public class OverrideCheck extends Doclet {

	private static final String DEBUG_SWITCH = "-debug";
	
	private static final String OVERRIDE_ANNOTATION_TYPE = "java.lang.Override";

	public static LanguageVersion languageVersion() {
		return LanguageVersion.JAVA_1_5;
	}

	public static int optionLength(String option) {
		return option.equals("-debug") ? 1 : 0;
	}
	
	public static boolean start(RootDoc root) {

		//record number of errors so we know to fail
		int errorCount = 0;
		
		//look for debug flag
		boolean debug = false;
		for (String[] opts : root.options()) {
			if (opts.length == 1 && opts[0].equals(DEBUG_SWITCH)) debug = true;
		}
		
		//walk every class
		for (ClassDoc clss : root.classes()) {
			if (debug) System.out.println("class:      " + clss);
			//optimization: don't examine interfaces
			if (clss.isInterface()) continue;
			//walk every method in the class
			for (MethodDoc method : clss.methods(false)) {
				if (debug) System.out.println("method:     " + method);
				
				//identify if the method has an override annotation
				AnnotationDesc[] annotations = method.annotations();
				boolean override = false;
				for (AnnotationDesc annotation : annotations) {
					if (debug) System.out.println("annotation:   @" + annotation.annotationType());
					override = override || annotation.annotationType().qualifiedTypeName().equals(OVERRIDE_ANNOTATION_TYPE);
					if (!debug && override) break;
				}
				
				if (override) {
					//is the override annotation compatible with Java 1.5?
					MethodDoc supr = method.overriddenMethod();
					if (supr == null) {
						//identify the interface that contains the overridden method
						supr = findOverriddenInterface(clss, method);
						//output a message on stdout accordingly
						if (supr == null) {
							System.out.println("WARNING: " + clss.name() + "." + method.name() + " OVERRIDES UNKNOWN");
						} else {
							System.out.println("ERROR:   " + clss.name() + "." + method.name() + " OVERRIDES INTERFACE " + supr.containingClass());
							errorCount++;
						}
					}
				}
			}
		}
		
		return errorCount == 0;
	}

	private static MethodDoc findOverriddenInterface(final Type type, final MethodDoc method) {
		final ClassDoc clss = type.asClassDoc();
		if (clss == null) return null;
		//look on interface
		if (clss.isInterface()) {
			for (MethodDoc supr : clss.methods(false)) {
				if (method.overrides(supr)) return supr; 
			}
		}
		//look on super interfaces
		for (Type superType : clss.interfaceTypes()) {
			final MethodDoc supr = findOverriddenInterface(superType, method);
			if (supr != null) return supr;
		}
		return null;
	}
	
}
