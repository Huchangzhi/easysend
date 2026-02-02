use anyhow::Result;
use flutter_rust_bridge::frb;
use tokio::sync::Mutex;
use std::sync::Arc;
use easytier::launcher::{NetworkInstance, NetworkConfig, NetworkingMethod};
use easytier::common::config::TomlConfigLoader;

pub struct EasyTierNetworkConfig {
    pub network_name: String,
    pub network_secret: String,
    pub public_server_url: String,
}

pub struct EasyTierDevice {
    pub ip: String,
    pub device_name: String,
    pub device_id: String,
}

pub struct EasyTierManager {
    is_running: bool,
    network_instance: Option<NetworkInstance>,
    network_config: Option<EasyTierNetworkConfig>,
}

impl EasyTierManager {
    pub fn new() -> Self {
        Self {
            is_running: false,
            network_instance: None,
            network_config: None,
        }
    }

    pub async fn start_network(&mut self, config: EasyTierNetworkConfig) -> Result<()> {
        println!("Starting EasyTier network: {}", config.network_name);

        // Create EasyTier network configuration
        let mut network_config = NetworkConfig::default();
        network_config.network_name = Some(config.network_name.clone());
        network_config.network_secret = Some(config.network_secret.clone());
        network_config.networking_method = Some(NetworkingMethod::PublicServer as i32);
        network_config.public_server_url = Some(config.public_server_url.clone());

        // Generate a random instance ID
        network_config.instance_id = Some(uuid::Uuid::new_v4().to_string());

        // Create the TOML configuration
        let toml_config = network_config.gen_config()?;

        // Create network instance
        let instance = NetworkInstance::new(toml_config, Default::default());

        // Start the instance
        if let Err(e) = instance.start() {
            return Err(anyhow::anyhow!("Failed to start EasyTier instance: {}", e));
        }

        self.network_instance = Some(instance);
        self.network_config = Some(config);
        self.is_running = true;

        Ok(())
    }

    pub async fn stop_network(&mut self) -> Result<()> {
        println!("Stopping EasyTier network");

        if let Some(instance) = self.network_instance.take() {
            // In a real implementation, we would properly stop the instance
            // For now, we just drop it which should clean up resources
        }

        self.is_running = false;
        self.network_config = None;
        Ok(())
    }

    pub fn is_network_running(&self) -> bool {
        self.is_running
    }

    pub fn get_network_config(&self) -> Option<&EasyTierNetworkConfig> {
        self.network_config.as_ref()
    }
}

// Global instance of EasyTier manager
static EASYTIER_MANAGER: once_cell::sync::Lazy<Mutex<EasyTierManager>> =
    once_cell::sync::Lazy::new(|| Mutex::new(EasyTierManager::new()));

#[frb(sync)]
pub fn easytier_start_network(network_name: String, network_secret: String, public_server_url: String) -> Result<bool> {
    let runtime = tokio::runtime::Runtime::new().unwrap();
    runtime.block_on(async {
        let mut manager = EASYTIER_MANAGER.lock().await;
        let config = EasyTierNetworkConfig {
            network_name,
            network_secret,
            public_server_url,
        };

        match manager.start_network(config).await {
            Ok(_) => Ok(true),
            Err(e) => {
                eprintln!("Failed to start EasyTier network: {}", e);
                Ok(false)
            }
        }
    })
}

#[frb(sync)]
pub fn easytier_stop_network() -> Result<bool> {
    let runtime = tokio::runtime::Runtime::new().unwrap();
    runtime.block_on(async {
        let mut manager = EASYTIER_MANAGER.lock().await;

        match manager.stop_network().await {
            Ok(_) => Ok(true),
            Err(e) => {
                eprintln!("Failed to stop EasyTier network: {}", e);
                Ok(false)
            }
        }
    })
}

#[frb(sync)]
pub fn easytier_is_running() -> bool {
    let runtime = tokio::runtime::Runtime::new().unwrap();
    runtime.block_on(async {
        let manager = EASYTIER_MANAGER.lock().await;
        manager.is_network_running()
    })
}