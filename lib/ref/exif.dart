class Exif {
  // constants used by GPS related Exif tags
  // they are locale independent
  static const String latitudeNorth = 'N';
  static const String latitudeSouth = 'S';
  static const String longitudeEast = 'E';
  static const String longitudeWest = 'W';

  static String getColorSpaceDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'sRGB';
      case 65535:
        return 'Uncalibrated';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getContrastDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Normal';
      case 1:
        return 'Soft';
      case 2:
        return 'Hard';
      default:
        return 'Unknown ($value)';
    }
  }

  // adapted from `metadata-extractor`
  static String getCompressionDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Uncompressed';
      case 2:
        return 'CCITT 1D';
      case 3:
        return 'T4/Group 3 Fax';
      case 4:
        return 'T6/Group 4 Fax';
      case 5:
        return 'LZW';
      case 6:
        return 'JPEG (old-style)';
      case 7:
        return 'JPEG';
      case 8:
        return 'Adobe Deflate';
      case 9:
        return 'JBIG B&W';
      case 10:
        return 'JBIG Color';
      case 99:
        return 'JPEG';
      case 262:
        return 'Kodak 262';
      case 32766:
        return 'Next';
      case 32767:
        return 'Sony ARW Compressed';
      case 32769:
        return 'Packed RAW';
      case 32770:
        return 'Samsung SRW Compressed';
      case 32771:
        return 'CCIRLEW';
      case 32772:
        return 'Samsung SRW Compressed 2';
      case 32773:
        return 'PackBits';
      case 32809:
        return 'Thunderscan';
      case 32867:
        return 'Kodak KDC Compressed';
      case 32895:
        return 'IT8CTPAD';
      case 32896:
        return 'IT8LW';
      case 32897:
        return 'IT8MP';
      case 32898:
        return 'IT8BL';
      case 32908:
        return 'PixarFilm';
      case 32909:
        return 'PixarLog';
      case 32946:
        return 'Deflate';
      case 32947:
        return 'DCS';
      case 34661:
        return 'JBIG';
      case 34676:
        return 'SGILog';
      case 34677:
        return 'SGILog24';
      case 34712:
        return 'JPEG 2000';
      case 34713:
        return 'Nikon NEF Compressed';
      case 34715:
        return 'JBIG2 TIFF FX';
      case 34718:
        return 'Microsoft Document Imaging (MDI) Binary Level Codec';
      case 34719:
        return 'Microsoft Document Imaging (MDI) Progressive Transform Codec';
      case 34720:
        return 'Microsoft Document Imaging (MDI) Vector';
      case 34892:
        return 'Lossy JPEG';
      case 65000:
        return 'Kodak DCR Compressed';
      case 65535:
        return 'Pentax PEF Compressed';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getCustomRenderedDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Normal process';
      case 1:
        return 'Custom process';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getExifVersionDescription(String valueString) {
    if (valueString.length == 4) {
      final major = int.tryParse(valueString.substring(0, 2));
      final minor = int.tryParse(valueString.substring(2, 4));
      if (major != null && minor != null) {
        return '$major.$minor';
      }
    }
    return valueString;
  }

  static String getExposureModeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Auto exposure';
      case 1:
        return 'Manual exposure';
      case 2:
        return 'Auto bracket';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getExposureProgramDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Manual';
      case 2:
        return 'Normal program';
      case 3:
        return 'Aperture priority';
      case 4:
        return 'Shutter priority';
      case 5:
        return 'Creative program';
      case 6:
        return 'Action program';
      case 7:
        return 'Portrait mode';
      case 8:
        return 'Landscape mode';
      default:
        return 'Unknown ($value)';
    }
  }

  // adapted from `metadata-extractor`
  static String getFileSourceDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Film Scanner';
      case 2:
        return 'Reflection Print Scanner';
      case 3:
        return 'Digital Still Camera (DSC)';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getLightSourceDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Unknown';
      case 1:
        return 'Daylight';
      case 2:
        return 'Fluorescent';
      case 3:
        return 'Tungsten (Incandescent)';
      case 4:
        return 'Flash';
      case 9:
        return 'Fine Weather';
      case 10:
        return 'Cloudy Weather';
      case 11:
        return 'Shade';
      case 12:
        return 'Daylight Fluorescent (D 5700 – 7100K)';
      case 13:
        return 'Day White Fluorescent (N 4600 – 5400K)';
      case 14:
        return 'Cool White Fluorescent (W 3900 – 4500K)';
      case 15:
        return 'White Fluorescent (WW 3200 – 3700K)';
      case 16:
        return 'Warm White Fluorescent (WW 2600 - 3250K)';
      case 17:
        return 'Standard light A';
      case 18:
        return 'Standard light B';
      case 19:
        return 'Standard light C';
      case 20:
        return 'D55';
      case 21:
        return 'D65';
      case 22:
        return 'D75';
      case 23:
        return 'D50';
      case 24:
        return 'ISO Studio Tungsten';
      case 255:
        return 'Other';
      default:
        return 'Unknown ($value)';
    }
  }

  // adapted from `metadata-extractor`
  static String getOrientationDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Top, left side (Horizontal / normal)';
      case 2:
        return 'Top, right side (Mirror horizontal)';
      case 3:
        return 'Bottom, right side (Rotate 180)';
      case 4:
        return 'Bottom, left side (Mirror vertical)';
      case 5:
        return 'Left side, top (Mirror horizontal and rotate 270 CW)';
      case 6:
        return 'Right side, top (Rotate 90 CW)';
      case 7:
        return 'Right side, bottom (Mirror horizontal and rotate 90 CW)';
      case 8:
        return 'Left side, bottom (Rotate 270 CW)';
      default:
        return 'Unknown ($value)';
    }
  }

  // adapted from `metadata-extractor`
  static String getPhotometricInterpretationDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'WhiteIsZero';
      case 1:
        return 'BlackIsZero';
      case 2:
        return 'RGB';
      case 3:
        return 'RGB Palette';
      case 4:
        return 'Transparency Mask';
      case 5:
        return 'CMYK';
      case 6:
        return 'YCbCr';
      case 8:
        return 'CIELab';
      case 9:
        return 'ICCLab';
      case 10:
        return 'ITULab';
      case 32803:
        return 'Color Filter Array';
      case 32844:
        return 'Pixar LogL';
      case 32845:
        return 'Pixar LogLuv';
      case 32892:
        return 'Linear Raw';
      default:
        return 'Unknown ($value)';
    }
  }

  // adapted from `metadata-extractor`
  static String getPlanarConfigurationDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Chunky (contiguous for each subsampling pixel)';
      case 2:
        return 'Separate (Y-plane/Cb-plane/Cr-plane format)';
      default:
        return 'Unknown ($value)';
    }
  }

  // adapted from `metadata-extractor`
  static String getResolutionUnitDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return '(No unit)';
      case 2:
        return 'Inch';
      case 3:
        return 'cm';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGainControlDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'None';
      case 1:
        return 'Low gain up';
      case 2:
        return 'High gain up';
      case 3:
        return 'Low gain down';
      case 4:
        return 'High gain down';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getMeteringModeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Unknown';
      case 1:
        return 'Average';
      case 2:
        return 'Center weighted average';
      case 3:
        return 'Spot';
      case 4:
        return 'Multi-spot';
      case 5:
        return 'Pattern';
      case 6:
        return 'Partial';
      case 255:
        return 'Other';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getSaturationDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Normal';
      case 1:
        return 'Low saturation';
      case 2:
        return 'High saturation';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getSceneCaptureTypeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Standard';
      case 1:
        return 'Landscape';
      case 2:
        return 'Portrait';
      case 3:
        return 'Night scene';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getSceneTypeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Directly photographed image';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getSensingMethodDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Not defined';
      case 2:
        return 'One-chip colour area sensor';
      case 3:
        return 'Two-chip colour area sensor';
      case 4:
        return 'Three-chip colour area sensor';
      case 5:
        return 'Colour sequential area sensor';
      case 7:
        return 'Trilinear sensor';
      case 8:
        return 'Colour sequential linear sensor';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getSharpnessDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Normal';
      case 1:
        return 'Soft';
      case 2:
        return 'Hard';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getSubjectDistanceRangeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Unknown';
      case 1:
        return 'Macro';
      case 2:
        return 'Close view';
      case 3:
        return 'Distant view';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getWhiteBalanceDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Auto';
      case 1:
        return 'Manual';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getYCbCrPositioningDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 1:
        return 'Centered';
      case 2:
        return 'Co-sited';
      default:
        return 'Unknown ($value)';
    }
  }

  // Flash

  static String getFlashModeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Unknown';
      case 1:
        return 'Compulsory flash firing';
      case 2:
        return 'Compulsory flash suppression';
      case 3:
        return 'Auto mode';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getFlashReturnDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'No strobe return detection';
      case 2:
        return 'Strobe return light not detected';
      case 3:
        return 'Strobe return light detected';
      default:
        return 'Unknown ($value)';
    }
  }

  // GPS

  static String getGPSAltitudeRefDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Above sea level';
      case 1:
        return 'Below sea level';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGPSDifferentialDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 0:
        return 'Without correction';
      case 1:
        return 'Correction applied';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGPSDirectionRefDescription(String value) {
    switch (value) {
      case 'T':
        return 'True direction';
      case 'M':
        return 'Magnetic direction';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGPSMeasureModeDescription(String valueString) {
    final value = int.tryParse(valueString);
    if (value == null) return valueString;
    switch (value) {
      case 2:
        return 'Two-dimensional measurement';
      case 3:
        return 'Three-dimensional measurement';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGPSDestDistanceRefDescription(String value) {
    switch (value) {
      case 'K':
        return 'kilometers';
      case 'M':
        return 'miles';
      case 'N':
        return 'knots';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGPSSpeedRefDescription(String value) {
    switch (value) {
      case 'K':
        return 'kilometers per hour';
      case 'M':
        return 'miles per hour';
      case 'N':
        return 'knots';
      default:
        return 'Unknown ($value)';
    }
  }

  static String getGPSStatusDescription(String value) {
    switch (value) {
      case 'A':
        return 'Measurement in progress';
      case 'V':
        return 'Measurement is interoperability';
      default:
        return 'Unknown ($value)';
    }
  }
}
