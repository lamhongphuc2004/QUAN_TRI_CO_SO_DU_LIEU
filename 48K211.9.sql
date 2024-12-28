CREATE DATABASE QuanLyNguyenLieu
GO
USE QuanLyNguyenLieu
GO

--Tao bang NhaCungCap
CREATE TABLE NhaCungCap (
    MaNCC CHAR(7) NOT NULL PRIMARY KEY,
    TenNCC NVARCHAR(50) NOT NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    SDT CHAR(10) UNIQUE NOT NULL
)
GO
--Tao bang NguyenLieu
CREATE TABLE NguyenLieu (
    MaNL CHAR(7) NOT NULL PRIMARY KEY,
    TenNL NVARCHAR(50),
    SoLuong INT NOT NULL,
    DVT NVARCHAR(10) NOT NULL,
    HSD DATE NOT NULL
)
GO
--Tao bang PhieuNhapKho
CREATE TABLE PhieuNhapKho (
    MaNK CHAR(7) NOT NULL PRIMARY KEY,
    NgayNhap DATE NOT NULL,
    MaNCC CHAR(7) NOT NULL,
    FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC)
)
GO
--Tao bang PhieuNhapKhoChiTiet
CREATE TABLE PhieuNhapKhoChiTiet (
    MaNKCT CHAR(7) NOT NULL PRIMARY KEY,
    MaNK CHAR(7) NOT NULL,
    MaNL CHAR(7) NOT NULL,
    SoLuongNhap INT NOT NULL,
    DonGia INT NOT NULL,
    FOREIGN KEY (MaNK) REFERENCES PhieuNhapKho(MaNK),
    FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL)
)
GO
--Tao bang PhieuXuatKho
CREATE TABLE PhieuXuatKho (
    MaXK CHAR(7) NOT NULL PRIMARY KEY,
    NgayXuat DATE NOT NULL
)
GO
--Tao bang PhieuXuatChiTiet
CREATE TABLE PhieuXuatKhoChiTiet (
    MaXKCT CHAR(7) NOT NULL PRIMARY KEY,
    MaXK CHAR(7) NOT NULL,
    MaNL CHAR(7) NOT NULL,
    SoLuongXuat INT,
    FOREIGN KEY (MaXK) REFERENCES PhieuXuatKho(MaXK),
    FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL)
)
GO
--Tao bang PhieuKiemKho
CREATE TABLE PhieuKiemKho (
    MaKK CHAR(7) NOT NULL PRIMARY KEY,
    NgayKiem DATE NOT NULL
)
GO
--Tao bang PhieuKiemKhoChiTiet
CREATE TABLE PhieuKiemKhoChiTiet (
    MaKKCT CHAR(7) NOT NULL PRIMARY KEY,
    MaKK CHAR(7) NOT NULL,
    MaNL CHAR(7) NOT NULL,
    SoLuongKiem INT NOT NULL ,
    HSD DATE,
	GhiChu NVARCHAR(100), 
    FOREIGN KEY (MaKK) REFERENCES PhieuKiemKho(MaKK),
    FOREIGN KEY (MaNL) REFERENCES NguyenLieu(MaNL)
)
GO
--Thêm 1000 dòng dữ liệu cho bảng NhaCungCap
CREATE PROCEDURE ThemNhaCungCap
AS
BEGIN
    DECLARE  @i INT,
			 @MaNCC CHAR(7),
			 @TenNCC NVARCHAR(50),
			 @DiaChi NVARCHAR(100),
			 @SDT CHAR(10)

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        
        SET @MaNCC = 'NCC' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4)
        SET @TenNCC = N'Nhà Cung Cấp ' + CAST(@i AS NVARCHAR(50))
        SET @DiaChi = N'Địa chỉ ' + CAST(@i AS NVARCHAR(100))
		SET @SDT= '0' + RIGHT('000000000' + CAST(CAST(RAND() * 999999999 AS INT) AS VARCHAR(10)),9)
        INSERT INTO NhaCungCap (MaNCC, TenNCC, DiaChi, SDT)
        VALUES (@MaNCC, @TenNCC, @DiaChi, @SDT)

        SET @i = @i + 1
    END
END

GO 
EXEC ThemNhaCungCap
SELECT * FROM NhaCungCap

--Thêm 1000 dòng dữ liệu vào bảng NguyenLieu
GO
CREATE  PROCEDURE ThemNguyenLieu
AS
BEGIN
    DECLARE @i INT,
            @MaNL CHAR(7),
            @TenNL NVARCHAR(50),
            @SoLuong INT,
            @DVT NVARCHAR(10),
            @HSD DATE

    SET @i = 1

	DECLARE @DVTList TABLE (DVT NVARCHAR(10))
	INSERT INTO @DVTList (DVT) VALUES (N'kg'), (N'chai'), (N'gói'), (N'lít')

    WHILE @i <= 1000
    BEGIN
        SET @MaNL = 'NL' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5)
        SET @TenNL = N'Nguyên Liệu ' + CAST(@i AS NVARCHAR(50))
        SET @SoLuong = @i * 10
        SELECT @DVT = DVT 
        FROM @DVTList 
        ORDER BY NEWID()
        SET @HSD = DATEADD(YEAR, 1, GETDATE())

        INSERT INTO NguyenLieu (MaNL, TenNL, SoLuong, DVT, HSD)
        VALUES (@MaNL, @TenNL, @SoLuong, @DVT, @HSD)

        SET @i = @i + 1
    END
END
GO
EXEC ThemNguyenLieu
SELECT * FROM NguyenLieu


--Thêm 1000 dòng dữ liệu vào bảng PhieuNhapKho
GO
CREATE PROCEDURE ThemPhieuNhapKho
AS
BEGIN
    DECLARE @i INT,
            @MaNK CHAR(7),
            @NgayNhap DATE,
            @MaNCC CHAR(7)

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        SET @MaNK = 'NK' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5)
        SET @NgayNhap = DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID()) % 30), GETDATE())
        SELECT TOP 1 @MaNCC = MaNCC FROM NhaCungCap 
        ORDER BY NEWID()
        INSERT INTO PhieuNhapKho (MaNK, NgayNhap, MaNCC)
        VALUES (@MaNK, @NgayNhap, @MaNCC)

        SET @i = @i + 1
    END
END
GO
EXEC ThemPhieuNhapKho
SELECT * FROM PhieuNhapKho


--Thêm 1000 dòng dữ liệu vào bảng PhieuNhapKhoChiTiet
GO
CREATE PROCEDURE ThemPhieuNhapKhoChiTiet
AS
BEGIN
    DECLARE @i INT,
            @MaNKCT CHAR(7),
            @MaNK CHAR(7),
            @MaNL CHAR(7),
            @SoLuongNhap INT,
            @DonGia INT

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        SET @MaNKCT = 'NCT' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4)

        SELECT TOP 1 @MaNK = MaNK 
        FROM PhieuNhapKho 
        ORDER BY NEWID()

        SELECT TOP 1 @MaNL = MaNL 
        FROM NguyenLieu 
        ORDER BY NEWID()

        SET @SoLuongNhap = ABS(CHECKSUM(NEWID()) % 100) + 1
		SET @DonGia = ABS(CHECKSUM(NEWID()) % 990001) + 10000

        INSERT INTO PhieuNhapKhoChiTiet (MaNKCT, MaNK, MaNL, SoLuongNhap, DonGia)
        VALUES (@MaNKCT, @MaNK, @MaNL, @SoLuongNhap, @DonGia)

        SET @i = @i + 1
    END
END
GO
EXEC ThemPhieuNhapKhoChiTiet
SELECT * FROM PhieuNhapKhoChiTiet


--Thêm 1000 dòng dữ liệu vào bảng PhieuXuatKho
GO
CREATE PROCEDURE ThemPhieuXuatKho
AS
BEGIN
    DECLARE @i INT,
            @MaXK CHAR(7),
            @NgayXuat DATE

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        SET @MaXK = 'XK' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5)
        SET @NgayXuat = DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID()) % 30), GETDATE())

        INSERT INTO PhieuXuatKho (MaXK, NgayXuat)
        VALUES (@MaXK, @NgayXuat);

        SET @i = @i + 1
    END
END
GO
EXEC ThemPhieuXuatKho
SELECT * FROM PhieuXuatKho


--Thêm 1000 dòng dữ liệu vào bảng PhieuXuatKhoChiTiet
GO
CREATE PROCEDURE ThemPhieuXuatKhoChiTiet
AS
BEGIN
    DECLARE @i INT,
            @MaXKCT CHAR(7),
            @MaXK CHAR(7),
            @MaNL CHAR(7),
            @SoLuongXuat INT

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        SET @MaXKCT = 'XCT' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4)

        SELECT TOP 1 @MaXK = MaXK 
        FROM PhieuXuatKho 
        ORDER BY NEWID()

        SELECT TOP 1 @MaNL = MaNL 
        FROM NguyenLieu 
        ORDER BY NEWID()

        SET @SoLuongXuat = ABS(CHECKSUM(NEWID()) % 100) + 1

        INSERT INTO PhieuXuatKhoChiTiet (MaXKCT, MaXK, MaNL, SoLuongXuat)
        VALUES (@MaXKCT, @MaXK, @MaNL, @SoLuongXuat)

        SET @i = @i + 1
    END
END
GO
EXEC ThemPhieuXuatKhoChiTiet
SELECT * FROM  PhieuXuatKhoChiTiet


--Thêm 1000 dòng dữ liệu vào bảng ThemPhieuKiemKho
GO
CREATE  PROCEDURE ThemPhieuKiemKho
AS
BEGIN
    DECLARE @i INT,
            @MaKK CHAR(7),
            @NgayKiem DATETIME

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        SET @MaKK = 'KK' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5)
        SET @NgayKiem = DATEADD(DAY, -1 * ABS(CHECKSUM(NEWID()) % 30), GETDATE())

        INSERT INTO PhieuKiemKho (MaKK, NgayKiem)
        VALUES (@MaKK, @NgayKiem)

        SET @i = @i + 1
    END
END
GO
EXEC ThemPhieuKiemKho
SELECT * FROM PhieuKiemKho


--Thêm 1000 dòng dữ liệu vào bảng PhieuKiemKhoChiTiet
GO
CREATE PROCEDURE ThemPhieuKiemKhoChiTiet
AS
BEGIN
    DECLARE @i INT,
            @MaKKCT CHAR(7),
            @MaKK CHAR(7),
            @MaNL CHAR(7),
            @SoLuongKiem INT,
            @HSD DATE,
            @GhiChu NVARCHAR(100)

    SET @i = 1

    WHILE @i <= 1000
    BEGIN
        SET @MaKKCT = 'KCT' + RIGHT('0000' + CAST(@i AS VARCHAR(4)), 4)
        SET @MaKK = 'KK' + RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID()) % 1000) + 1) AS VARCHAR(5)), 5) 
        SET @MaNL = 'NL' + RIGHT('0000' + CAST((ABS(CHECKSUM(NEWID()) % 100) + 1) AS VARCHAR(5)), 5)  
        SET @SoLuongKiem = ABS(CHECKSUM(NEWID()) % 100) + 1 
        SET @HSD = DATEADD(DAY, (ABS(CHECKSUM(NEWID()) % 365)), GETDATE())  
        SET @GhiChu = N'Ghi chú ' + CAST(@i AS NVARCHAR(10))

        INSERT INTO PhieuKiemKhoChiTiet (MaKKCT, MaKK, MaNL, SoLuongKiem, HSD, GhiChu)
        VALUES (@MaKKCT, @MaKK, @MaNL, @SoLuongKiem, @HSD, @GhiChu)

        SET @i = @i + 1
    END
END
GO
EXEC ThemPhieuKiemKhoChiTiet
SELECT * FROM PhieuKiemKhoChiTiet



--1.Stored Procedure Thêm mới nhà cung cấp
CREATE OR ALTER PROCEDURE sp_ThemMoiNhaCungCap
    @MaNCC CHAR(7),
    @TenNCC NVARCHAR(50),
    @DiaChi NVARCHAR(100),
    @SDT CHAR(10)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NhaCungCap WHERE MaNCC = @MaNCC)
    BEGIN
        PRINT N'Mã nhà cung cấp đã tồn tại!'
        RETURN
    END

    IF EXISTS (SELECT 1 FROM NhaCungCap WHERE SDT = @SDT)
    BEGIN
        PRINT N'Số điện thoại đã tồn tại!'
        RETURN
    END

    IF LEN(@SDT) != 10
    BEGIN
        PRINT N'Số điện thoại phải gồm 10 chữ số!'
        RETURN
    END

    INSERT INTO NhaCungCap (MaNCC, TenNCC, DiaChi, SDT)
    VALUES (@MaNCC, @TenNCC, @DiaChi, @SDT)

END
GO

--2.Trigger kiểm tra trước khi xóa nhà cung cấp, đảm bảo đảm bảo nhà cung cấp đó không có liên quan đến các phiếu nhập kho trong bảng PhieuNhapKho.
GO
CREATE OR ALTER TRIGGER tCheckTruocKhiXoaNCC
ON NhaCungCap
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @MaNCC CHAR(7)
    SELECT @MaNCC = deleted.MaNCC FROM deleted
    
    IF EXISTS (SELECT 1 FROM PhieuNhapKho WHERE MaNCC = @MaNCC)
    BEGIN
        PRINT N'Không thể xóa nhà cung cấp này vì đang có phiếu nhập liên quan'
        ROLLBACK
    END
    ELSE
    BEGIN
        DELETE FROM NhaCungCap WHERE MaNCC = @MaNCC
    END
END
GO

--3. Stored Procedure Thêm mới nguyên liệu
CREATE OR ALTER PROCEDURE sp_ThemNguyenLieu
    @MaNL CHAR(7),
    @TenNL NVARCHAR(50),
    @SoLuong INT,
    @DVT NVARCHAR(10),
    @HSD DATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NguyenLieu WHERE MaNL = @MaNL)
    BEGIN
        PRINT N'Nguyên liệu đã tồn tại!'
    END
    ELSE
    BEGIN
        INSERT INTO NguyenLieu (MaNL, TenNL, SoLuong, DVT, HSD)
        VALUES (@MaNL, @TenNL, @SoLuong, @DVT, @HSD)
        PRINT N'Nguyên liệu đã được thêm thành công!'
    END
END
GO

--4. Funtion Kiểm tra hạn sử dụng nguyên liệu
CREATE OR ALTER FUNCTION f_KiemTraHSD (@MaNL CHAR(7))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @HSD DATE, @KetQua NVARCHAR(50)
    
    SELECT @HSD = HSD FROM NguyenLieu WHERE MaNL = @MaNL
    
    IF @HSD < GETDATE()
    BEGIN
        SET @KetQua = N'Nguyên liệu đã hết hạn'
    END
    ELSE
    BEGIN
        SET @KetQua = N'Nguyên liệu còn hạn sử dụng'
    END
    
    RETURN @KetQua
END
GO

--5. Function lấy ra danh sách nguyên liệu hết HSD
CREATE FUNCTION f_LayNguyenLieuHetHan()
RETURNS TABLE
AS
RETURN
(
    SELECT MaNL, TenNL, SoLuong, DVT, HSD
    FROM NguyenLieu
    WHERE HSD <= GETDATE()
)
GO


--6. Stored Procedure Kiểm tra ngày nhập
CREATE or ALTER PROC sp_kiemtrangaynhap
    (@MaNK CHAR(7), @tb varchar (50) output)
AS
BEGIN
	declare @NgayNhap DATE

	SELECT @NgayNhap = NgayNhap
	from PhieuNhapKho
	WHERE @MaNK= MaNK

    IF @NgayNhap > GETDATE()
    BEGIN
        set @tb = N'Ngày nhập không hợp lệ'
    END
	else 
		set @tb = N'Ngày nhập hợp lệ'
END
GO

--7. Trigger Kiểm tra đơn giá nhập , đảm bảo đơn giá không được âm
CREATE TRIGGER tKiemTraDonGia
ON PhieuNhapKhoChiTiet
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DonGia < 0)
    BEGIN
        PRINT N'Đơn giá không được âm!'  
        ROLLBACK
    END
END
GO

--8.Trigger Kiểm tra số lượng nhập, đảm bảo số lượng nhập không được âm
CREATE OR ALTER TRIGGER tKiemTraSoLuongNhap
ON PhieuNhapKhoChiTiet
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE SoLuongNhap < 0)
    BEGIN
        PRINT N'Số lượng nhập không được âm!'  
        ROLLBACK 
    END
END
GO

--9. Trigger xóa phiếu nhập kho chi tiết khi xóa phiếu nhập kho
CREATE TRIGGER tXoaPhieuNhapKhoChiTiet
ON PhieuNhapKho
AFTER DELETE
AS
BEGIN
    DELETE FROM PhieuNhapKhoChiTiet
    WHERE MaNK IN (SELECT MaNK FROM deleted)
END
GO

--10. Trigger Cập nhật số lượng nguyên liệu khi nhập kho
CREATE OR ALTER TRIGGER tCapNhatSoLuongNhap
ON PhieuNhapKhoChiTiet
AFTER INSERT
AS
BEGIN
    DECLARE @MaNL CHAR(7), @SoLuongNhap INT

    SELECT @MaNL = inserted.MaNL, @SoLuongNhap = inserted.SoLuongNhap
    FROM inserted

    UPDATE NguyenLieu
    SET SoLuong = SoLuong + @SoLuongNhap
    WHERE MaNL = @MaNL
END
GO

--11. Stored Procdure Tính Tổng Giá Trị Nhập Kho
CREATE OR ALTER PROCEDURE sp_TinhTongGiaTriNhapKho (@MaNK CHAR(7))
AS
BEGIN
    DECLARE @TongGiaTri INT
    
    SELECT @TongGiaTri = SUM(SoLuongNhap * DonGia)
    FROM PhieuNhapKhoChiTiet
    WHERE MaNK = @MaNK
    
    PRINT N'Tổng giá trị nhập kho là: ' + CAST(@TongGiaTri AS NVARCHAR(50))
END
GO

--12. Trigger kiểm tra ngày xuất, đảm bảo ngày xuất không là ngày trong tương lai
CREATE TRIGGER tKiemTraNgayXuat
ON PhieuXuatKho
AFTER INSERT
AS
BEGIN
    DECLARE @NgayXuat DATE
    SELECT @NgayXuat = NgayXuat FROM inserted
 
    IF @NgayXuat > GETDATE()
    BEGIN
    	PRINT N'Ngày xuất không hợp lệ! Ngày xuất phải không lớn hơn ngày hiện tại.';
    	ROLLBACK
    END
END
GO

--13. Trigger kiểm tra số lượng xuất, đảm bảo số lượng xuất không <0 và > số lượng tồn kho
CREATE OR ALTER TRIGGER tKiemTraSoLuongXuat
ON PhieuXuatKhoChiTiet
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaNL CHAR(7), @SoLuongXuat INT, @SoLuongTon INT

    SELECT @MaNL = inserted.MaNL, 
           @SoLuongXuat = inserted.SoLuongXuat
    FROM inserted

    SELECT @SoLuongTon = SoLuong 
    FROM NguyenLieu 
    WHERE MaNL = @MaNL

    IF @SoLuongXuat < 0
    BEGIN
        PRINT N'Số lượng xuất không được âm!'
        ROLLBACK 
    END

    IF @SoLuongXuat > @SoLuongTon
    BEGIN
        PRINT N'Số lượng xuất không được lớn hơn số lượng tồn kho!'
        ROLLBACK 
    END
END
GO

--14. Trigger Cập nhật số lượng nguyên liệu khi xuất kho
CREATE OR ALTER TRIGGER tCapNhatSoLuongXuat
ON PhieuXuatKhoChiTiet
AFTER INSERT
AS
BEGIN
    DECLARE @MaNL CHAR(7), @SoLuongXuat INT

    SELECT @MaNL = inserted.MaNL, @SoLuongXuat = inserted.SoLuongXuat
    FROM inserted

    UPDATE NguyenLieu
    SET SoLuong = SoLuong - @SoLuongXuat
    WHERE MaNL = @MaNL
END
GO

--15. Trigger xoá phiếu xuất chi tiết khi xoá phiếu xuất kho
CREATE OR ALTER TRIGGER tXoaPhieuXuatChiTiet
ON PhieuXuatKho
FOR DELETE
AS
BEGIN
	DELETE FROM PhieuXuatKhoChiTiet
	WHERE MaXK IN (SELECT MaXK FROM deleted)
END
GO

--16. Trigger Cập nhật lại số lượng nguyên liệu sau khi xóa phiếu xuất kho
CREATE OR ALTER TRIGGER tCapNhatSoLuongKhiXoaPX
ON PhieuXuatKhoChiTiet
AFTER DELETE
AS
BEGIN
    DECLARE @MaNL CHAR(7)
    DECLARE @SoLuongXuat INT

    SELECT @MaNL = deleted.MaNL, @SoLuongXuat = deleted.SoLuongXuat
    FROM deleted

    UPDATE NguyenLieu
    SET SoLuong = SoLuong + @SoLuongXuat
    WHERE MaNL = @MaNL
END
GO


--17. Trigger Cập Nhật Số Lượng Kiểm Kho
CREATE OR ALTER TRIGGER tCapNhatSoLuongKiemKho
ON NguyenLieu
AFTER UPDATE
AS
BEGIN
    DECLARE @MaNL CHAR(7), @SoLuong INT

    SELECT @MaNL = inserted.MaNL, @SoLuong = inserted.SoLuong
    FROM inserted

    UPDATE PhieuKiemKhoChiTiet
    SET SoLuongKiem = @SoLuong
    WHERE MaNL = @MaNL
END
GO

--18. Trigger Kiểm tra mã nguyên liệu (mỗi mã nguyên liệu chỉ xuất hiện 1 lần trong phiếu kiểm)
CREATE OR ALTER TRIGGER tKiemTraMaNguyenLieuPK
ON PhieuKiemKhoChiTiet
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT MaNL
        FROM inserted
        GROUP BY MaNL
        HAVING COUNT(*) > 1
    )
    BEGIN
        PRINT N'Mỗi mã nguyên liệu chỉ được phép xuất hiện 1 lần trong 1 phiếu kiểm!'
        ROLLBACK 
    END
END
GO

--19. Trigger Xóa phiếu kiểm kho chi tiết khi xóa phiếu kiểm kho
CREATE OR ALTER TRIGGER tXoaPhieuKiemChiTiet
ON PhieuKiemKho
FOR DELETE
AS
BEGIN
	
	DELETE FROM PhieuKiemKhoChiTiet
	WHERE MaKK IN (SELECT MaKK FROM deleted)
END
GO

--20. Stored Procedure Kiểm tra ngày kiểm hợp lệ (<= ngày hien tai)
CREATE OR ALTER PROC sp_kiemtrangaykiem (@MaKK CHAR(7), @NgayKiem DATE)
AS
BEGIN
	DECLARE @tb varchar (50)
	SELECT @NgayKiem = NgayKiem
	FROM PhieuKiemKho
	WHERE @MaKK= MaKK
   	IF @NgayKiem > GETDATE()
    	BEGIN
        	SET @tb = N'Ngày Kiểm không hợp lệ'
    	END
	ELSE
		SET @tb = N'Ngày Kiểm nhập hợp lệ'
END


