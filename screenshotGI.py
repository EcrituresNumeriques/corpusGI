import sys
import time
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from PyQt4.QtWebKit import *

class Screenshot(QWebView):
    def __init__(self):
        self.app = QApplication(sys.argv)
        QWebView.__init__(self)
        self._loaded = False
        self.loadFinished.connect(self._loadFinished)

    def capture(self, url, output_file):
        self.load(QUrl(url))
        self.wait_load()
        # set to webpage size
        frame = self.page().mainFrame()
        # originaly :
            # self.page().setViewportSize(frame.contentsSize())
        # to force the size of webpage, use instead :
        self.page().setViewportSize(QSize(1200, 1024))
        # render image
        image = QImage(self.page().viewportSize(), QImage.Format_ARGB32)
        painter = QPainter(image)
        frame.render(painter)
        painter.end()
        print ('saving', output_file)
        image.save(output_file)

    def wait_load(self, delay=0):
        # process app events until page loaded
        while not self._loaded:
            self.app.processEvents()
            time.sleep(delay)
        self._loaded = False

    def _loadFinished(self, result):
        self._loaded = True

s = Screenshot()
s.capture('http://remue.net/spip.php?article3322','item-001.png')
s.capture('http://remue.net/spip.php?article1524','item-002.png')
s.capture('http://remue.net/spip.php?article1528','item-003.png')
s.capture('http://remue.net/spip.php?article4126','item-004.png')
s.capture('http://remue.net/spip.php?article3125','item-005.png')
s.capture('http://remue.net/spip.php?article2998','item-006.png')
s.capture('http://remue.net/spip.php?article1656','item-007.png')
s.capture('http://remue.net/spip.php?article1519','item-008.png')
s.capture('http://remue.net/spip.php?article1518','item-009.png')
s.capture('http://remue.net/spip.php?article642','item-010.png')
s.capture('http://remue.net/spip.php?article601','item-011.png')
s.capture('http://remue.net/spip.php?article2381','item-012.png')
s.capture('http://remue.net/spip.php?article3320','item-013.png')
s.capture('http://remue.net/spip.php?article2702','item-014.png')
s.capture('http://remue.net/spip.php?article2439','item-015.png')
s.capture('http://remue.net/spip.php?article3108','item-016.png')
s.capture('http://remue.net/spip.php?article2156','item-017.png')
s.capture('http://remue.net/spip.php?article2681','item-018.png')
s.capture('http://remue.net/spip.php?article1502','item-019.png')
s.capture('http://remue.net/spip.php?article2843','item-020.png')
s.capture('http://remue.net/spip.php?article2813','item-021.png')
s.capture('http://remue.net/spip.php?article3489','item-022.png')
s.capture('http://remue.net/spip.php?article2533','item-023.png')
s.capture('http://remue.net/spip.php?article2309','item-024.png')
s.capture('http://remue.net/spip.php?article2385','item-025.png')
s.capture('http://remue.net/spip.php?article1521','item-026.png')
s.capture('http://remue.net/spip.php?article2108','item-027.png')
s.capture('http://remue.net/spip.php?article2577','item-028.png')
s.capture('http://remue.net/spip.php?article1503','item-029.png')
s.capture('http://remue.net/spip.php?article2505','item-030.png')
s.capture('http://www.generalinstin.net/le-livre/etape-3/','item-031.png')
s.capture('http://www.generalinstin.net/le-livre/etape-1/','item-032.png')
s.capture('http://www.generalinstin.net/le-livre/etape-2/','item-033.png')
s.capture('http://www.generalinstin.net/le-livre/etape-3b/','item-034.png')
s.capture('http://www.generalinstin.net/le-livre/etape-4/','item-035.png')
s.capture('http://www.generalinstin.net/le-livre/etape-5/','item-036.png')
s.capture('http://www.generalinstin.net/le-livre/etape-6/','item-037.png')
s.capture('http://www.generalinstin.net/le-livre/etape-6-recit-de-lediteur/','item-038.png')
s.capture('http://remue.net/spip.php?article6033','item-039.png')
s.capture('http://remue.net/spip.php?article8271','item-040.png')
s.capture('http://remue.net/spip.php?article8062','item-041.png')
s.capture('http://remue.net/spip.php?article6827','item-042.png')
s.capture('http://remue.net/spip.php?article6682','item-043.png')
s.capture('http://remue.net/spip.php?article5144','item-044.png')
s.capture('http://remue.net/spip.php?article4592','item-045.png')
s.capture('http://remue.net/spip.php?article4426','item-046.png')
s.capture('http://remue.net/spip.php?article2035','item-047.png')
s.capture('http://remue.net/spip.php?article3962','item-048.png')
s.capture('http://remue.net/spip.php?article3612','item-049.png')
s.capture('http://remue.net/spip.php?article2829','item-050.png')
s.capture('http://remue.net/spip.php?article1522','item-051.png')
s.capture('http://remue.net/spip.php?article8082','item-052.png')
s.capture('http://remue.net/spip.php?article7536','item-053.png')
s.capture('http://remue.net/spip.php?article7236','item-054.png')
s.capture('http://remue.net/spip.php?article6851','item-055.png')
s.capture('http://remue.net/spip.php?article6703','item-056.png')
