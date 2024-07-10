SELECT *
FROM [Nashville Housing].dbo.['Housing Data']


----------------------------------------
--Estandarizar la fecha


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Nashville Housing].dbo.['Housing Data']

UPDATE ['Housing Data']
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE ['Housing Data']
ADD SaleDateConverted Date;

UPDATE ['Housing Data']
SET SaleDateConverted = CONVERT(Date, SaleDate)



----------------------------------------
-- Completar columna PropertyAddress


SELECT *
FROM [Nashville Housing].dbo.['Housing Data']
--WHERE PropertyAddress is null
ORDER BY ParcelID

--Al usar ISNULL podemos revisar si el primer parametro es nulo y reemplazar con el segundo.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing].dbo.['Housing Data'] a
JOIN [Nashville Housing].dbo.['Housing Data'] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing].dbo.['Housing Data'] a
JOIN [Nashville Housing].dbo.['Housing Data'] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


------------------------------------------------------------
--Separacion de PropertyAddress en Address, City, Satte


SELECT PropertyAddress
FROM [Nashville Housing].dbo.['Housing Data']
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City

FROM [Nashville Housing].dbo.['Housing Data']


--Añadir nuevas columnas

ALTER TABLE ['Housing Data']
ADD PropertySplitAddress Nvarchar(255);

UPDATE ['Housing Data']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE ['Housing Data']
ADD PropertySplitCity Nvarchar(255);

UPDATE ['Housing Data']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM [Nashville Housing].dbo.['Housing Data']


------------------------------------------------------------
--Separacion de OwnerAddress en Address, City, Satte

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.') , 3),
PARSENAME(REPLACE(OwnerAddress,',','.') , 2),
PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
FROM [Nashville Housing].dbo.['Housing Data']


--Añadir nuevas columnas

ALTER TABLE ['Housing Data']
ADD OwnerSplitAddress Nvarchar(255);

UPDATE ['Housing Data']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)



ALTER TABLE ['Housing Data']
ADD OwnerSplitCity Nvarchar(255);

UPDATE ['Housing Data']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)


ALTER TABLE ['Housing Data']
ADD OwnerSplitState Nvarchar(255);

UPDATE ['Housing Data']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

SELECT *
FROM [Nashville Housing].dbo.['Housing Data']


------------------------------------------------------------
--Cambiar Y & N por Yes & No en columna "SoldAsVacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing].dbo.['Housing Data']
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [Nashville Housing].dbo.['Housing Data']


UPDATE ['Housing Data']
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

--------------------

--Remover duplicados


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [Nashville Housing].dbo.['Housing Data'])
SELECT *
FROM RowNumCTE WHERE row_num > 1


--------------------------------------

--Borrar las columnas que nos se usan, en este caso SaleDate, TaxDistrict, OwnerAddress & PropertyAddress

SELECT * 
FROM [Nashville Housing].dbo.['Housing Data']

ALTER TABLE [Nashville Housing].dbo.['Housing Data']
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress
