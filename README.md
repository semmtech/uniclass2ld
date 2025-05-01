# uniclass2ld

The uniclass2ld script formats Uniclass publications as Linked Data. Uniclass is a unified classification system used in the UK construction industry. Uniclass is maintained by NBS and publications thereof, available under the [CC BY-ND 4.0](http://creativecommons.org/licenses/by-nd/4.0/) license, can be found at https://uniclass.thenbs.com. The uniclass2ld script complies with that license as it offers a change in format only. The CC BY-ND 4.0 license applies to the Uniclass publications regardless of format, including the Linked Data format obtained using this script. The uniclass2ld script itself, however, is available under the [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) license in order to ensure the formatting process, including any updates and improvements to it, remains open and transparent. The resulting Linked Data has been [made available in full](https://market.laceshub.com/en-US?searchText=uniclass) on the Laces Data Platform.


## Run
### Prerequisites

This PowerShell script relies on the open source [ImportExcel module](https://github.com/dfinke/ImportExcel/), which can be installed from PowerShell using the command ```Install-Module ImportExcel```.

In order to be allowed to run PowerShell scripts on your machine, you may need to change the execution policy. For instance, the following command in PowerShell will allow you to run scripts within the current PowerShell process: ```Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process```. More permanent changes to the policy beyond the current process are possible too, although they are considered a larger security risk of running malicious scripts.

### Parameters
The uniclass2ld script takes two parameters:
* ```-dir <string>```: directory in which Uniclass Excel files reside (e.g., "data\uniclass-all-2025-01")
* ```-v <string>```: optional parameter indicating the version of the Uniclass data (e.g., "2025-01"); if this parameter is not supplied, the last 7 characters from the -dir parameter will be used instead

The Linked Data output is written to standard output, which can be redirected to a new Turtle file as in the example below:

```.\uniclass2ld.ps1 -dir "example\uniclass-sample-2025-01" > example\uniclass-sample-2025-01.ttl```

Know that Windows PowerShell version 7 and up will by default output files encoded as BOM-less UTF-8, a common encoding that some pieces of software require. Earlier versions may differ. Please verify and/or change the encoding to your needs of any files you create through the uniclass2ld process. 


## Uniclass in Linked Data

The uniclass2ld script reads Excel tables from a Uniclass publication and formats them as Linked Data using standardized terminology for representing classes and properties. The URIs identifying the Uniclass classifications are the URLs already adopted by NBS to present readers with documentation. In effect, the URIs are therefore dereferenceable and lead back to the authoritative source for Uniclass.

A Uniclass publication is identified as an ontology in Linked Data, as seen in the example below:
```
<https://uniclass.thenbs.com>
    a owl:Ontology ;
    skos:prefLabel   "Uniclass"@en ;
    owl:versionInfo  "2025-01"@en ;
    dct:license      "http://creativecommons.org/licenses/by-nd/4.0/" ;
    .
```

The majority of the available Uniclass classifications, part of a hierarchy, are formatted thus:
```
<https://uniclass.thenbs.com/taxon/ss_30_36_10>
    a owl:Class ;
    skos:prefLabel   "Ceiling hatch systems"@en ;
    skos:notation    "Ss_30_36_10" ;
    owl:versionInfo  "Systems v1.37, January 2025"@en ;
    rdfs:subClassOf  <https://uniclass.thenbs.com/taxon/ss_30_36> ;
    rdfs:seeAlso     "COBie: Ss_30_36_10 : Ceiling hatch systems"@en ;
    .
```

The only classifications from Uniclass that are not expressed as classes in Linked Data are those from the table "Properties and characteristics", which, as the name suggests, are considered to be properties rather than classes. The following snippet shows the Linked Data format for one such property:
```
<https://uniclass.thenbs.com/taxon/pc_10_15_92>
    a rdf:Property ;
    skos:prefLabel      "Uniform resource locator (URL)"@en ;
    skos:notation       "PC_10_15_92" ;
    owl:versionInfo     "Properties and characteristics v1.3, January 2025"@en ;
    rdfs:subPropertyOf  <https://uniclass.thenbs.com/taxon/pc_10_15> ;
    .
```

## License
This code is copyrighted by [Semmtech B.V.](https://semmtech.com) and released under the [GPL 3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) license.