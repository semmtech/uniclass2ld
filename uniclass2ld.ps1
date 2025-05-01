# SPDX-License-Identifier: GPL-3.0-or-later
# Author: Sander Stolk
# Copyright (C) 2025  Semmtech B.V. (https://semmtech.com)


# LICENSE STATEMENT:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # directory in which Uniclass Excel files reside (e.g., ".\uniclass-all-2025-01")
    [string]$dir = ".\",
    # version of the Uniclass data (e.g., "2025-01"); 
    # if not supplied, will use last 7 characters from $dir instead
    [string]$v
)


#########################################
#            FUNCTIONS                  #
#########################################

#########################################
# Function: returns the necessary prefixes in the Turtle serialization
#########################################
function Prefixes-Turtle {
  Write-Output @"
@base  <https://uniclass.thenbs.com/taxon/> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix dct:  <http://purl.org/dc/terms/> .
`r`n
"@
}

#########################################
# Function: returns the Uniclass ontology in the Turtle serialization
#########################################
function UniClassOntology-Turtle {
  param (
    [string]$Version
  )

  Write-Output @"
<https://uniclass.thenbs.com> a owl:Ontology ;
    skos:prefLabel `"`"`"Uniclass`"`"`"@en ;
    owl:versionInfo """$Version"""@en ;
    rdfs:comment """This dataset contains Uniclass as expressed in the Linked Data format. This format was created through an automated script available at <https://github.com/semmtech/uniclass2ld>, and complies with the CC BY-ND 4.0 license of the Uniclass publication, since it is not a derivative but only a change in format. The original Uniclass dataset can be found at <https://uniclass.thenbs.com>."""@en ;
    dct:license "http://creativecommons.org/licenses/by-nd/4.0/" ;
    .
`r`n
"@
}

#########################################
# Function: returns a Linked Data resource (type Class or Property) in the Turtle serialization
#########################################
function LDResource-Turtle {
  param (
    [string]$Type,
    [string]$Title,
    [string]$Code,
    [string]$Version,
    [string]$SuperCode,
    [string]$Refs
  )
  
  if ($Type -eq "Property") {
    $type = "rdf:Property"
    $subPredicate = "rdfs:subPropertyOf"
  } else {
    $type = "owl:Class"
    $subPredicate = "rdfs:subClassOf"
  }
  
  Write-Output @"
<$($code.ToLower())> a $type ;
    skos:prefLabel `"`"`"$Title`"`"`"@en ;
    skos:notation `"$Code`" ;
    owl:versionInfo """$Version"""@en ;
$(if (![string]::IsNullOrEmpty($SuperCode)) {
"    $subPredicate <$($SuperCode.ToLower())> ;`r`n"
})$(if (![string]::IsNullOrEmpty($Refs)) {
"    rdfs:seeAlso `"`"`"" + $Refs + "`"`"`"@en ;`r`n" 
})    .
`r`n
"@
}


#########################################
#               MAIN                    #
#########################################

# try to ascertain Uniclass version
$uniclassVersion = $v;
if ([string]::IsNullOrEmpty($v) -and ($dir.Length -gt 7)) {
  $uniclassVersion = $dir.Substring($dir.Length-7,7)
}

# output Turtle with prefixes and ontology
Prefixes-Turtle
UniClassOntology-Turtle -Version $uniclassVersion

# change tables from Excel format to Turtle format
$excelFiles = Get-ChildItem -Path $dir -Filter "Uniclass2015_*_v*.xlsx" -File
foreach ($excelFile in $excelFiles) {
  # From Excel content, get the table info from cell A1
  $data = Import-Excel $excelFile.FullName -NoHeader -StartRow 1 -Raw
  $info = $data[0].psobject.properties["P1"].Value
  if (![string]::IsNullOrEmpty($info)) {
    # e.g. "Ss Systems - January 2025 - v1.37"
    $infoParts = $info -split " - "
    $tableTitle = $infoParts[0].Substring(3,$infoParts[0].Length-3)
    $code = $infoParts[0].Substring(0,2)
    $title = $tableTitle
    $date = $infoParts[1]
    $version = "$tableTitle $($infoParts[2]), $date" 
    $type = "Class"
    if ($code.toLower() -eq "pc") {
      $type = "Property";
    }    
    # output Uniclass resource in Turtle format
    LDResource-Turtle -Type $type -Title $title -Code $code -Version $version -SuperCode $null -Refs $null 
  }
  
  # From Excel content, get the table body
  $data = Import-Excel $excelFile.FullName -StartRow 3 -Raw
  foreach ($row in $data) {
    $code  = $row.psobject.properties["Code"].Value
    $title = $row.psobject.properties["Title"].Value
    $superCode = $code.Substring(0,$code.Length-3)
    $type = "Class"
    if ($code.Substring(0,2).toLower() -eq "pc") {
      $type = "Property";
    }
    $refs = ""
    foreach ($prop in $row.psobject.properties.GetEnumerator()) {
      if (![string]::IsNullOrEmpty($prop.Value) -and @("Code", "Group", "Sub group", "Section", "Object", "Sub object", "Title") -notcontains $prop.Name) {
        if (![string]::IsNullOrEmpty($refs)) {
          $refs += "`r`n"
        }
        $refs += "$($prop.Name): $($prop.Value)"
      }
    }
    # output Uniclass resource in Turtle format
    LDResource-Turtle -Type $type -Title $title -Code $code -Version $version -SuperCode $superCode -Refs $refs 
  }
}
