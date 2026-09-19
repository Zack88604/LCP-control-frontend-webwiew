using System;
using System.Drawing;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;

namespace LcpControlOnly
{
    internal static class SettingsStore
    {
        internal const string DefaultFrontendUrl = "http://192.168.50.32:5174/data-collection";

        private static readonly string SettingsDirectory = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "LCP Control");
        private static readonly string SettingsPath = Path.Combine(SettingsDirectory, "settings.json");

        internal static Uri LoadFrontendUri()
        {
            try
            {
                return NormalizeFrontendUri(LoadSettings().FrontendUrl);
            }
            catch
            {
                // A bad or incomplete local settings file must not prevent the
                // collection controller from starting.
                return NormalizeFrontendUri(DefaultFrontendUrl);
            }
        }

        internal static Uri SaveFrontendUri(string value)
        {
            var uri = NormalizeFrontendUri(value);
            var settings = LoadSettings();
            settings.FrontendUrl = uri.AbsoluteUri;
            SaveSettings(settings);
            return uri;
        }

        internal static Rectangle? LoadWindowBounds()
        {
            var settings = LoadSettings();
            if (settings.WindowWidth <= 0 || settings.WindowHeight <= 0)
            {
                return null;
            }

            return new Rectangle(
                settings.WindowLeft,
                settings.WindowTop,
                settings.WindowWidth,
                settings.WindowHeight);
        }

        internal static void SaveWindowBounds(Rectangle bounds)
        {
            if (bounds.Width <= 0 || bounds.Height <= 0)
            {
                return;
            }

            var settings = LoadSettings();
            settings.WindowLeft = bounds.Left;
            settings.WindowTop = bounds.Top;
            settings.WindowWidth = bounds.Width;
            settings.WindowHeight = bounds.Height;
            SaveSettings(settings);
        }

        internal static Uri NormalizeFrontendUri(string value)
        {
            var requestedUrl = string.IsNullOrWhiteSpace(value) ? DefaultFrontendUrl : value.Trim();
            Uri uri;
            if (!Uri.TryCreate(requestedUrl, UriKind.Absolute, out uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                throw new InvalidOperationException("前端地址必须是有效的 http 或 https 地址。");
            }

            var builder = new UriBuilder(uri);
            if (builder.Path == "/")
            {
                builder.Path = "/data-collection";
            }
            return builder.Uri;
        }

        private static PersistedSettings LoadSettings()
        {
            try
            {
                if (!File.Exists(SettingsPath))
                {
                    return new PersistedSettings();
                }

                using (var stream = File.OpenRead(SettingsPath))
                {
                    var serializer = new DataContractJsonSerializer(typeof(PersistedSettings));
                    return serializer.ReadObject(stream) as PersistedSettings ?? new PersistedSettings();
                }
            }
            catch
            {
                return new PersistedSettings();
            }
        }

        private static void SaveSettings(PersistedSettings settings)
        {
            Directory.CreateDirectory(SettingsDirectory);

            var temporaryPath = SettingsPath + ".tmp";
            using (var stream = File.Create(temporaryPath))
            {
                var serializer = new DataContractJsonSerializer(typeof(PersistedSettings));
                serializer.WriteObject(stream, settings);
            }

            File.Copy(temporaryPath, SettingsPath, true);
            File.Delete(temporaryPath);
        }

        [DataContract]
        private sealed class PersistedSettings
        {
            [DataMember(Name = "frontendUrl")]
            internal string FrontendUrl { get; set; }

            [DataMember(Name = "windowLeft")]
            internal int WindowLeft { get; set; }

            [DataMember(Name = "windowTop")]
            internal int WindowTop { get; set; }

            [DataMember(Name = "windowWidth")]
            internal int WindowWidth { get; set; }

            [DataMember(Name = "windowHeight")]
            internal int WindowHeight { get; set; }
        }
    }
}
