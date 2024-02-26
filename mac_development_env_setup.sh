#!/bin/bash

# Define logging functions with datetime stamps
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

log_warn() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $1"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

# Ensure Homebrew is installed and set up
setup_homebrew() {
    if ! command -v brew &>/dev/null; then
        log_info "Homebrew not installed. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? -ne 0 ]; then
            log_error "Failed to install Homebrew. Exiting."
            exit 1
        fi
    else
        log_info "Homebrew is already installed. Updating and upgrading Homebrew..."
        brew update && brew upgrade
    fi
}

# Install development tools with Homebrew
install_with_brew() {
    log_info "Installing $1..."
    brew install $2
    if [ $? -ne 0 ]; then
        log_warn "Failed to install $1 with Homebrew."
    else
        log_info "$1 installation completed successfully with Homebrew."
    fi
}

# Install Python packages
install_python_packages() {
    log_info "Installing Python packages..."
    # Define Python packages to install
    declare -a python_packages=(
        "pandas"
        "tensorflow"
        "transformers"
        "keras"
    )

    for package in "${python_packages[@]}"; do
        pip3 install "$package"
        if [ $? -ne 0 ]; then
            log_warn "Failed to install Python package $package."
        else
            log_info "Python package $package installed successfully."
        fi
    done
}

# Function to append environment variables to both .zshrc and .bashrc
append_to_shell_profiles() {
    variable_declaration=$1
    echo "$variable_declaration" | tee -a $HOME/.zshrc $HOME/.bashrc >/dev/null
    log_info "Appended '${variable_declaration}' to .zshrc and .bashrc"
}

# Fetch and display system information
display_system_info() {
    log_info "Fetching and displaying system information..."

    # System Software Overview
    log_info "System Software Overview:"
    sw_vers

    # Hardware Overview
    log_info "Hardware Overview:"
    system_profiler SPHardwareDataType

    # Memory Information
    log_info "Memory Information:"
    system_profiler SPMemoryDataType

    # Storage Information
    log_info "Storage Information:"
    system_profiler SPStorageDataType

    # Graphics/Displays Information
    log_info "Graphics/Displays Information:"
    system_profiler SPDisplaysDataType

    # Network Information
    log_info "Network Information:"
    system_profiler SPNetworkDataType

    # Battery Information (relevant for MacBook models)
    log_info "Battery Information:"
    system_profiler SPBatteryDataType
}


# Main installation block
main() {
    # Execute the function to display system info
    display_system_info

    setup_homebrew

    # Install development tools using Homebrew
    declare -a brew_software=(
        "git"
        "hadoop"
        "apache-spark"
        "hive"
        "hbase"
        "apache-airflow"
        "elasticsearch"
        "mysql"
        "postgresql"
        "openjdk@11"
        "scala"
    )

    for software in "${brew_software[@]}"; do
        install_with_brew "$software" "$software"
    done


    # Install Python packages
    install_python_packages

    # Reminder for manual configurations
    log_info "Installation and basic configuration complete. Please manually configure additional details for services like Elasticsearch, Airflow, and Hadoop ecosystem components as needed."

    # Set JAVA_HOME for OpenJDK 11.
    JAVA_HOME="$(brew --prefix)/opt/openjdk@11"
    append_to_shell_profiles "export JAVA_HOME=${JAVA_HOME}"

    # Set HADOOP_HOME.
    HADOOP_HOME="$(brew --prefix)/opt/hadoop/libexec"
    append_to_shell_profiles "export HADOOP_HOME=${HADOOP_HOME}"

    # Set SPARK_HOME.
    SPARK_HOME="$(brew --prefix)/opt/apache-spark/libexec"
    append_to_shell_profiles "export SPARK_HOME=${SPARK_HOME}"

    # Set HBASE_HOME.
    HBASE_HOME="$(brew --prefix)/opt/hbase/libexec"
    append_to_shell_profiles "export HBASE_HOME=${HBASE_HOME}"

    # Refresh shell configurations.
    source $HOME/.zshrc
    source $HOME/.bashrc

    log_info "Installation and configuration completed. Please restart your terminal for the changes to take effect."
}

# Execute the main function
main

