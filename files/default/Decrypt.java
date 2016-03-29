import java.io.IOException;
import java.io.InputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.adobe.granite.crypto.CryptoException;
import com.adobe.granite.crypto.internal.jsafe.JSafeCryptoSupport;

/**
 * The class that is able to decrypt aem passwords.
 * <p/>
 * We need to keep the functionality in one class (!) as we would like to use it without maven.
 * See also RND-380 for further details.
 */
public class Decrypt extends JSafeCryptoSupport {

	static final int EXIT_STATUS_SUCCESS = 0;

	private static final int WRONG_NUMBER_OF_ARGUMENTS = 1;

	private static final int ERRORS_WHILE_READING_KEY = 2;

	private static final int ERRORS_WHILE_DECRYPTING = 3;

	private static final int ERRORS_WHILE_INITIALIZING = 4;

	private static final int KEY_FILE_NOT_EXISTS = 5;

	private static final Logger LOG = LoggerFactory.getLogger(Decrypt.class);

	int exitStatus = EXIT_STATUS_SUCCESS;

	Decrypt() throws Exception {
		super();
	}

	public static void main(String[] args) throws Exception {
		if (args.length != 2) {
			printUsage();
			System.exit(WRONG_NUMBER_OF_ARGUMENTS);
		} else {
			Decrypt decrypt = new Decrypt();
			decrypt.execute(args);
			System.exit(decrypt.exitStatus);
		}
	}

	private static void printUsage() {
		StringBuilder sb = new StringBuilder();
		sb.append("\n\tExactly two arguments are required: master key file and encrypted password\n");
		sb.append("\n");
		sb.append("\tCorrect call should look similar to:\n");
		sb.append(
				"\t\tAEM_LIBS=com.adobe.granite.crypto-3.0.8.jar:cryptojce-6.0.0.jar:cryptojcommon-6.0.0.jar:jcmFIPS-6.0.0.jar:jSafeCryptoSupport.jar\n");
		sb.append("\t\tLOG_LIBS=slf4j-api-1.7.6.jar:slf4j-api-1.7.12.jar;slf4j-simple-1.7.12.jar\n");
		sb.append("\t\tDECRYPT_CLASSPATH=.:$AEM_LIBS:$LOG_LIBS\n");
		sb.append("\n");
		sb.append(
				"\t\tjava -cp $DECRYPT_CLASSPATH Decrypt ./master {34e3797a19d462477f5b6be9d7e51998efc0d2f8873369476c1baef6fd62b527}");
		System.out.println(sb.toString());
	}

	void execute(String[] args) {
		String keyFilename = args[0];
		LOG.info("getting input stream for {}", keyFilename);
		InputStream is = getInputStream(keyFilename);
		if (is != null) {
			LOG.info("getting key from input stream...");
			byte[] masterKey = getKey(is);
			if (masterKey.length > 0) {
				LOG.info("initializing crypto with master key...");
				wrappedInit(masterKey);

				String encrypted = args[1];
				String plain = wrappedUnprotect(encrypted);
				if (plain != null) {
					LOG.info("password decrypted to: {}", plain);
					// print to stdout (log messages are printed to stderr)
					System.out.println(plain);
				} else {
					LOG.info("errors while decrypting password.");
				}
			} else {
				LOG.error("master key read from {} is empty", keyFilename);
			}
		}
	}

	private InputStream getInputStream(String keyFilename) {
		InputStream is = getClass().getResourceAsStream(keyFilename);
		if (is == null) {
			LOG.error("error while reading {} (file not exists)", keyFilename);
			exitStatus = KEY_FILE_NOT_EXISTS;
		}
		return is;
	}

	byte[] getKey(InputStream is) {
		byte[] targetArray = new byte[0];
		try {
			targetArray = new byte[is.available()];
			is.read(targetArray);
		} catch (IOException e) {
			LOG.error("error while reading bytes from master key file: {}", e.getMessage(), e);
			exitStatus = ERRORS_WHILE_READING_KEY;
		}
		return targetArray;
	}

	void wrappedInit(byte[] masterKey) {
		try {
			this.init(masterKey);
		} catch (Exception e) {
			LOG.error("error while initializing {} with masterKey {}: {}",
					JSafeCryptoSupport.class, masterKey, e.getMessage(), e);
			exitStatus = ERRORS_WHILE_INITIALIZING;
		}
	}

	String wrappedUnprotect(String encrypted) {
		String result = null;
		try {
			result = this.unprotect(encrypted);
		} catch (CryptoException e) {
			LOG.error("error while decrypting {}: {}", encrypted, e.getMessage(), e);
			exitStatus = ERRORS_WHILE_DECRYPTING;
		}
		return result;
	}
}
