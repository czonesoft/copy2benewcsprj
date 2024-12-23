# C#项目复制自动化脚本
# 陈震军 2024/12/23
$oldName = "LzOneHealth.LisCollection"
$newName = "LZOH.LisSvr"
$newGuid = [Guid]::NewGuid().ToString("B").ToUpper()

# 复制项目文件
Copy-Item -Path "$oldName\*" -Destination "$newName" -Recurse

# 更新项目文件中的GUID和名称
Get-ChildItem -Path $newName -Filter *.csproj -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace $oldName, $newName
    $content = $content -replace '<ProjectGuid>.*?</ProjectGuid>', "<ProjectGuid>$newGuid</ProjectGuid>"
    Set-Content -Path $_.FullName -Value $content
    # 重命名.csproj文件
    $newCsprojName = $_.Name -replace $oldName, $newName
    Rename-Item -Path $_.FullName -NewName $newCsprojName
}

# 处理.csproj.user文件
Get-ChildItem -Path $newName -Filter "*.csproj.user" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace $oldName, $newName
    # 重命名.csproj.user文件
    $newUserFileName = $_.Name -replace $oldName, $newName
    Set-Content -Path (Join-Path $_.DirectoryName $newUserFileName) -Value $content
    Remove-Item $_.FullName
}

# 处理新项目内的.sln文件
Get-ChildItem -Path $newName -Filter "*.sln" -Recurse | ForEach-Object {
    $newFileName = $_.Name -replace $oldName, $newName
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace $oldName, $newName
    $content = $content -replace 'Project\("\{.*?\}"\)', "Project(`"{$newGuid}`")"
    Set-Content -Path (Join-Path $_.DirectoryName $newFileName) -Value $content
    Remove-Item $_.FullName
}

# 更新所有.cs文件中的命名空间和using语句
Get-ChildItem -Path $newName -Filter "*.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    # 更新命名空间声明
    $content = $content -replace "namespace\s+$oldName", "namespace $newName"
    # 更新using语句
    $content = $content -replace "using\s+$oldName", "using $newName"
    # 更新其他引用
    $content = $content -replace "LzOneHealth\.LisCollection\.", "LZOH.LisSvr."
    Set-Content -Path $_.FullName -Value $content
}

# 更新AssemblyInfo.cs
Get-ChildItem -Path $newName -Filter "AssemblyInfo.cs" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace $oldName, $newName
    Set-Content -Path $_.FullName -Value $content
}
