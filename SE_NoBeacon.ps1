﻿
    $filePath = 'your save path here\SANDBOX_0_0_0_.sbs'
    $deletedlogs = "yourlogs path here\Admin Logs\Audits\deleted\"

    # ===== only change the above value

    $CurrentDateTime = Get-Date -Format "MM-dd-yyyy_HH-mm"
    $deletedfilename = "Owned_Audit_" +$CurrentDateTime+ ".log"
    $deletedpath = $deletedLogs + $deletedfilename
    
    [xml]$myXML = Get-Content $filePath -Encoding UTF8
    $ns = New-Object System.Xml.XmlNamespaceManager($myXML.NameTable)
    $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

    New-Item -path $deletedpath -type file

    Add-Content -path $deletedpath -Value "No-Beacon Check ... "
    Add-Content -path $deletedpath -Value "[  ]"
    
    #delete grid if no beacon, then if no wheels, rotor, piston pieces.
    $nodes = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase[(@xsi:type='MyObjectBuilder_CubeGrid')]"  , $ns) 
    ForEach($node in $nodes){
        $randombeacon = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Beacon')]/Owner" , $ns)
        $beaconcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Beacon']", $ns).count
            IF($beaconcount -eq 0){
                $ignoretotal = 0
                $rotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorRotor']", $ns).count
                $pistoncount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_PistonTop']", $ns).count
                $wheelcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Wheel']", $ns).count
                $advrotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorAdvancedRotor']", $ns).count
                $ignoretotal = $ignoretotal + $rotorcount + $pistoncount + $wheelcount + $advrotorcount
                IF($ignoretotal -eq 0){
                    Add-Content -path $deletedpath -Value "[$($node.DisplayName)] Deleted for no beacons"
                    Add-Content -path $deletedpath -Value "[  ]"
                    $node.ParentNode.RemoveChild($node)
                }
            }
            
            #remove the <# and #> at the top and bottom of this section to enable requiring beacons to be owned.
            <#
            ElseIf(($randombeacon|Get-Random) -eq $null){
                $ignoretotal = 0
                $rotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorRotor']", $ns)
                $pistoncount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_PistonTop']", $ns)
                $wheelcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Wheel']", $ns)
                $advrotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorAdvancedRotor']", $ns)
                $ignoretotal = $ignoretotal + $rotorcount.count + $pistoncount.count + $wheelcount.count + $advrotorcount.count
                IF($ignoretotal -eq 0){
                    Write-Host -ForegroundColor Green "[$($node.DisplayName)] Deleted for no beacon owner"
                    Add-Content -path $deletedpath -Value "[$($node.DisplayName)] Deleted for no beacon owner"
                    Add-Content -path $deletedpath -Value "[  ]"
                    $node.ParentNode.RemoveChild($node)
                }
            }
            #>
    }


    $myXML.Save($filePath)