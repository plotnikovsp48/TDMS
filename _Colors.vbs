' Преобразование даты в число
Function DateToLong(dDate)
  iYear = 365*datepart("yyyy", dDate)
  iday = datepart("y", dDate)
  DateToLong = iYear+iday
End Function

' Выбор цвета по градиенту
public function ColorScaleRYG(value, minValue, maxValue)
  dim midValue
  if IsNumeric(minValue) and IsNumeric(maxValue) then
    midValue = (CDbl(minValue) + CDbl(maxValue)) / 2
  end if

  if IsNumeric(value) and IsNumeric(midValue) and CDbl(value) < CDbl(midValue) then
    ColorScaleRYG = ColorScale(value, minValue, "#FFFFFF", midValue, "#FFFF00") '"#F8696B" , "#FFEB84" , EEEEEE , FFFF00
  else
    ColorScaleRYG = ColorScale(value, midValue, "#FFFF00", maxValue, "#FF0000") '"#FFEB84" , "#63BE7B"
  end if

end function

public function ColorScale(value, minValue, minColor, maxValue, maxColor)

  ColorScale = 0 'errorColor

  if not IsNumeric(value) or not IsNumeric(minValue) or not IsNumeric(maxValue) then
    exit function
  end if

  ' Do all calculations using doubles (can't mix doubles and decimals)
  value = CDbl(value)
  minValue = CDbl(minValue)
  maxValue = CDbl(maxValue)

  if minValue >= maxValue then
    exit function
  end if

  if value <= minValue then
    ColorScale = GetRGB(minColor)
    exit function
  end if
  if value >= maxValue then
    ColorScale = GetRGB(maxColor)
    exit function
  end if

  dim scaleValue, r, g, b 'as double
  dim minRGB, minR, minG, minB 'as integer
  dim maxRGB, maxR, maxG, maxB 'as integer

  scaleValue = (value - minValue) / (maxValue - minValue)

  minR = hex2dec(Mid(minColor, 2, 2))
  minG = hex2dec(Mid(minColor, 4, 2))
  minB = hex2dec(Mid(minColor, 6, 2))

  maxR = hex2dec(Mid(maxColor, 2, 2))
  maxG = hex2dec(Mid(maxColor, 4, 2))
  maxB = hex2dec(Mid(maxColor, 6, 2))

  r = minR + ((maxR - minR) * scaleValue)
  g = minG + ((maxG - minG) * scaleValue)
  b = minB + ((maxB - minB) * scaleValue)
  
  ColorScale = RGB(r,g,b)
end function

private function hex2dec(s)

Dim i,l
r=0
i=0
l=len(s)

while(l>=1)
  r=(r+((inStr("0123456789ABCDEF",Mid(s,l,1))-1)*(16^i)))
  i=(i+1)
  l=(l-1)
wend
hex2dec=r
End function


private function GetRGB(colorStr)

  GetRGB = 0

  if Mid(colorStr, 1,1)="#" then
    R = hex2dec (Mid(colorStr, 2, 2))
    G = hex2dec (Mid(colorStr, 4, 2))
    B = hex2dec (Mid(colorStr, 6, 2))
  else
    R = hex2dec (Mid(colorStr, 1, 2))
    G = hex2dec (Mid(colorStr, 3, 2))
    B = hex2dec (Mid(colorStr, 5, 2))
  end if
  
  GetRGB = GetColor (B, G, R) '(R, G, B)
end function

private function GetColor(R, G, B)
    GetColor = R * 2^16 + G * 2^8 + B
end function
