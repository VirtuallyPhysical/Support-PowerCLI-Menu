function VPF-Numa
{
clear
$ClustersNuma = Get-datacenter $Global:DCChoice | Get-Cluster $global:CLUChoice
ForEach ($c in $ClustersNuma){  
        For($e = 1; $e -le $ClustersNuma.count; $e++) {
            # Write-Progress -Activity "Processing Clusters" -status "Working on cluster - $c" ` -percentComplete ($e / $ClustersNuma.count*100)
        }

        #Process each host in cluster
        $NUMAStats = @()
        $largeMemVM = @()
        $largeCPUVM = @()

        $hosts = Get-VMHost -Location $c    

            ForEach ($h in $Hosts) {
                    $HostView = $h | Get-View
                    $HostSummary = "" | Select HostName, MemorySizeGB, CPUSockets, CPUCoresSocket, CPUCoresTotal, CPUThreads, NumNUMANodes, NUMANodeSize

                        #Get Host CPU, Memory & NUMA info
                        $HostSummary.HostName = $h.Name
                        $HostSummary.MemorySizeGB =([Math]::Round($HostView.hardware.memorysize / 1GB))
                        $HostSummary.CPUSockets = $HostView.hardware.cpuinfo.numCpuPackages
                        $HostSummary.CPUCoresSocket = ($HostView.hardware.cpuinfo.numCpuCores / $HostSummary.CPUSockets)
                        $HostSummary.CPUCoresTotal = $HostView.hardware.cpuinfo.numCpuCores
                        $HostSummary.CPUThreads = $HostView.hardware.cpuinfo.numCpuThreads
                        $HostSummary.NumNUMANodes = $HostView.hardware.numainfo.NumNodes
                        $HostSummary.NUMANodeSize =([Math]::Round($HostSummary.MemorySizeGB / $HostSummary.NumNUMANodes))
                        $NUMAStats += $HostSummary
            } 

                #Find the smallest NUMA Node (CPU & Mem) to use for comparison
                $x =  $HostSummary.NUMANodeSize | measure -Minimum
                $y =  $HostSummary.CPUCoresSocket | measure -Minimum

                #Get list of all VMs in cluster that are oversized
                $VMDeatils = @()
                $VMDeatils = Get-VM -Location $c | where {$_.NumCpu -gt $v.Minimum -or $_.MemoryGB -gt $y.Minimum}

                For($i = 1; $i -le $VMDeatils.count; $i++) {
                  #  Write-Progress -Activity "Processing VMs" ` -percentComplete ($i / $VMDeatils.count*100)
                }

                # VM Calculations
                #Large MEM VM - Any VM with more memory allocated then the NUMA node.
                $largeMemVM += $VMDeatils | Where-Object {$_.MemoryGB -gt $x.Minimum}

                #Large CPU VM - Any VM with more CPU then cores per Proc on a host
                $largeCPUVM += $VMDeatils | Where-Object {$_.NumCPU -gt $y.Minimum}
        
                #Display report for current cluster
						write-host
                        Write-Host "NUMA Node Specs for Cluster - $c." -ForegroundColor Green
                        $NUMAStats | ft
            
                  
                        Write-host $largeCPUVM.Count "VMs that Exceed CPUCoresSocket." -ForegroundColor Green
                        $largeCPUVM | select name, @{N='Memory GB';E={$_.MemoryGB}}, @{N='Num CPU';E={$_.ExtensionData.Config.Hardware.NumCPU}}, @{N='Num Sockets';E={($_.ExtensionData.Config.Hardware.NumCPU / $_.ExtensionData.Config.Hardware.NumCoresPerSocket)}}, @{N='Cores Per Socket';E={$_.ExtensionData.Config.Hardware.NumCoresPerSocket}}, @{N='CPU Hot Plug Status';E={$_.ExtensionData.Config.CpuHotAddEnabled}} | ft
                    

                    
                        Write-host $largeMemVM.Count "VMs that Exceed NUMA Node Memory size." -ForegroundColor Green
                        $largeMemVM | select name, @{N='Memory GB';E={$_.MemoryGB}}, @{N='Num CPU';E={$_.ExtensionData.Config.Hardware.NumCPU}}, @{N='Num Sockets';E={($_.ExtensionData.Config.Hardware.NumCPU / $_.ExtensionData.Config.Hardware.NumCoresPerSocket)}}, @{N='Cores Per Socket';E={$_.ExtensionData.Config.Hardware.NumCoresPerSocket}}, @{N='CPU Hot Plug Status';E={$_.ExtensionData.Config.CpuHotAddEnabled}} | ft
                  
write-host
write-host
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');			  
clear    
}
}
VPF-Numa