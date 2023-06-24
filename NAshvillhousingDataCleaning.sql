Select * 
FROM DataClean..housing

--Removing Time data
ALTER Table housing
Add UpdatedSaleDate Date

Update DataClean..housing
SET UpdatedSaleDate = CONVERT(Date,SaleDate)

--Deleting old SaleDate column
Alter Table housing
Drop Column SaleDate

--Filling in null values for property address
Select * 
From DataClean..housing
Order BY ParcelID

Select a.PropertyAddress,a.ParcelID,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
FROM DataClean..housing a
 JOIN DataClean..housing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET propertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
FROM DataClean..housing a
 JOIN DataClean..housing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]

Select propertyAddress
From DataClean..housing

--Creating Clearer address Tables
--Property Address
Select 
SUBSTRING(PropertyAddress, 1, CharIndex(',',PropertyAddress) -1) as Address
 ,SUBSTRING(PropertyAddress, CharIndex(',',PropertyAddress) +1, Len(PropertyAddress)) as City
 FROM DataClean..housing

Alter Table DataClean..housing
Add Address nvarchar(255)

Alter Table DataClean..housing
Add City nvarchar(255)

Update DataClean..housing
Set Address = SUBSTRING(PropertyAddress, 1, CharIndex(',',PropertyAddress) -1)

Update DataClean..housing
SET City = SUBSTRING(PropertyAddress, CharIndex(',',PropertyAddress) +1, Len(PropertyAddress))

--Owner Address
Select
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),3)
From DataClean..housing

ALTER table DataClean..housing
Add OwnerAddressnew nvarchar(255)
ALTER table DataClean..housing
Add OwnerCity nvarchar(255)
ALTER table DataClean..housing
Add OwnerState nvarchar(255)

Update DataClean..housing
SET OwnerAddressnew = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
Update DataClean..housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
Update DataClean..housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Converting Y,N to Yes,No
SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM DataClean..housing
Group By SoldAsVacant
Order BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'N' Then 'No'
    When SoldAsVacant = 'Y' Then 'Yes'
    Else SoldAsVacant
    END
From DataClean..housing

Update DataClean..housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' Then 'No'
    When SoldAsVacant = 'Y' Then 'Yes'
    Else SoldAsVacant
    END


--Removing Duplicates
With RowNumCTE AS(
SELECT *, 
    ROW_NUMBER() OVER(
	Partition By ParcelID,
	LegalReference,
	PropertyAddress,
	UpdatedSaleDate,
	SalePrice
	Order by UniqueID) row_num

FROM DataClean..housing
)
SELECT *
--DELETE
FROM RowNumCTE
Where row_num > 1

--





