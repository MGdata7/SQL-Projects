# Data Cleaning Project: Nashville Housing Data

This is a data cleaning project with housing data from Nashville, Tennessee in the United States. 

![homes](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/nashvillehomes.JPG)

Data cleaning is a key component of most data analytics and data science roles. While it's meticulous in any form, I can use SQL to speed it up. Once the data goes from dirty to clean, it's ready for analysis, which can inform business decisions and extract value from the data. Let's get started.

### Overview

First we'll get a view of the data.

```
SELECT * 
FROM dbo.NashvilleHousing
``` 
![view 1](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss1.JPG)
![view 2](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss2.JPG)

### Standardising Date

The date format includes YYYY/MM/DD as well as an hour/minute mark, the latter of which is zeros all the way down. We can't do much with that so let's clear out the hour and minute marks.

```
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing
``` 
There, now we have a date format we can work with. Looking much better now.

![view 3](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss3.JPG)

### Populating Address Data

Let's move on to the property address data. There are some values missing from the property address column.

![doing math](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/doingmath.jpg)

However, we might have the context clues from other parts of the dataset to reliably populate these fields. It looks like common parcel ID's share common addresses. Let's construct some code to populate the missing data.

```
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL
``` 
![view 5](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss5.JPG)

## Dividing Address Columns

Now the property address fields are nice and populated. The format of the address is difficult to work with, though - street address and city are both in one field. The owner address column is even more complex, with state information included at the end.

![view 6](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss6.JPG)

We can separate those into separate columns for simpler analysis.

``` 
SELECT PropertyAddress
FROM NashvilleHousing

SELECT
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
,Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
``` 
Great! Now address data is divided into street address, city, and state columns.

![view 7](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss7.JPG)

### Standardising Binary Values

Moving on to our "Sold as Vacant" column - we have four possible values: Y, N, Yes, and No. 

![view 8](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss8.JPG)

Let's try to make those elements a little more consistent. We'll replace "Y" and "N" with "Yes" and "No."

``` 
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing
``` 

Now the Yes/No values are standardised. Good.

![view 9](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss9.JPG)

### Removing Duplicate Rows

Moving on, we'll remove duplicates from the dataset.

``` 
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,
		     SaleDate,
		     LegalReference
		     ORDER BY
		     UniqueID
		     )row_num
FROM dbo.NashvilleHousing)

DELETE
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,
		     SaleDate,
		     LegalReference
		     ORDER BY
		     UniqueID
		     )row_num
FROM dbo.NashvilleHousing)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
``` 
No more duplicates - excellent.

![view 10](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/ss10.JPG)

### Removing Unused Columns

We still have some leftover columns with address and city data combined, as well as a date column containing the minutes count, so we'll clear them out. Typically I would avoid deleting raw data, but this is just for the purpose of this exercise.

``` 
SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
``` 
### The Project in Review

In this project, I took dirty data and made it easier to work with. I standardised the date column, populating missing address data, divided address columns, grouped/standardised binary values, removed duplicate rows, and removed leftover columns before the analysis.

![homestar runner is the bomb](https://github.com/MGdata7/DataCleaningNashvilleHousing/blob/9bc7bf2ee5e31bf2549f02e797935ce3e50c9198/itsover.jpg)
