import localUnitTest from './LocalUnit.test';
import cipherUtilsTest from './CipherUtils.test';

export default function testsuite() {
  localUnitTest();
  cipherUtilsTest();
}
