#!/bin/bash
# Curatenie: sterge rapoartele temporare de verificare. Nu modifica nimic altceva.
find / -xdev -name "diag-3938fa6768588173.txt" -not -path '/proc/*' -delete 2>/dev/null
rm -f /tmp/diag-3938fa6768588173.txt
